data "oci_identity_availability_domains" "available" {
  compartment_id = var.oci_tenancy_ocid
}

data "oci_core_images" "ubuntu_2404" {
  compartment_id           = var.oci_compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  oci_availability_domain_index = 1
  oci_ssh_ingress_cidr          = "68.228.89.239/32"
  oci_app_repository_url        = "https://github.com/jyablonski/baseline.git"
  oci_freeform_tags = {
    managed-by = "terraform"
    cost-scope = "oci-always-free"
  }

  oci_availability_domain = data.oci_identity_availability_domains.available.availability_domains[min(local.oci_availability_domain_index, length(data.oci_identity_availability_domains.available.availability_domains) - 1)].name
  oci_ubuntu_arm64_images = [
    for image in data.oci_core_images.ubuntu_2404.images : image
    if strcontains(lower(image.display_name), "aarch64")
  ]
  oci_ubuntu_image_id = local.oci_ubuntu_arm64_images[0].id
  oci_cloud_init = base64encode(templatefile("${path.module}/templates/oci-cloud-init.yaml.tftpl", {
    default_user   = "ubuntu"
    repository_url = local.oci_app_repository_url
  }))
}

# Always Free networking: consumes 1 VCN; 1 of the Free Tier tenancy's 2-VCN limit remains (VCNs themselves have no hourly charge).
resource "oci_core_vcn" "main" {
  cidr_blocks    = ["10.0.0.0/16"]
  compartment_id = var.oci_compartment_ocid
  display_name   = "oci-always-free-vcn"
  dns_label      = "ocifree"
  freeform_tags  = local.oci_freeform_tags
}

# Always Free networking: consumes 1 public regional subnet inside the VCN; no metered subnet allowance is consumed.
resource "oci_core_subnet" "public" {
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = var.oci_compartment_ocid
  display_name               = "oci-always-free-public-subnet"
  dns_label                  = "public"
  freeform_tags              = local.oci_freeform_tags
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  vcn_id                     = oci_core_vcn.main.id
}

# Always Free networking: consumes 1 internet gateway; it has no hourly charge and does not consume load-balancer allowances.
resource "oci_core_internet_gateway" "main" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "oci-always-free-internet-gateway"
  enabled        = true
  freeform_tags  = local.oci_freeform_tags
  vcn_id         = oci_core_vcn.main.id
}

# Always Free networking: consumes 1 route table; route tables have no hourly charge or separate Always Free quota.
resource "oci_core_route_table" "public" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "oci-always-free-public-routes"
  freeform_tags  = local.oci_freeform_tags
  vcn_id         = oci_core_vcn.main.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id
  }
}

# Always Free networking: consumes 1 security list; security lists have no hourly charge or separate Always Free quota.
resource "oci_core_security_list" "public" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "oci-always-free-public-security-list"
  freeform_tags  = local.oci_freeform_tags
  vcn_id         = oci_core_vcn.main.id

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }

  ingress_security_rules {
    protocol    = "6"
    source      = local.oci_ssh_ingress_cidr
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  # GitHub-hosted runners have dynamic source IPs; key-only public SSH is the deliberate tradeoff for CI reachability.
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 443
      min = 443
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.public_ingress_cidrs

    content {
      description = "NBA Postgres for DBeaver"
      protocol    = "6"
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      stateless   = false

      tcp_options {
        max = 5432
        min = 5432
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.public_ingress_cidrs

    content {
      description = "NBA MCP Streamable HTTP"
      protocol    = "6"
      source      = ingress_security_rules.value
      source_type = "CIDR_BLOCK"
      stateless   = false

      tcp_options {
        max = 8001
        min = 8001
      }
    }
  }

  ingress_security_rules {
    protocol    = "17"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    udp_options {
      max = 443
      min = 443
    }
  }

  ingress_security_rules {
    icmp_options {
      code = 4
      type = 3
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
  }
}

# Cost guardrail: tracks this compartment against a $1 monthly soft budget; budgets are free governance resources and consume no Always Free allowance. OCI budgets do not stop resources or charges.
resource "oci_budget_budget" "sandbox" {
  amount         = 1
  compartment_id = var.oci_tenancy_ocid
  description    = "Monthly soft budget for the OCI Always Free sandbox compartment."
  display_name   = "oci-always-free-sandbox"
  freeform_tags  = local.oci_freeform_tags
  reset_period   = "MONTHLY"
  target_type    = "COMPARTMENT"
  targets        = [var.oci_compartment_ocid]

  lifecycle {
    prevent_destroy = true
  }
}

# Preserve the existing Terraform address migration while replacing the x86 E2 instance with the ARM A1 instance.
moved {
  from = oci_core_instance.e2_micro
  to   = oci_core_instance.a1_flex
}

# Always Free compute/storage/networking: consumes the full A1 allowance of 2 OCPUs and 12 GB RAM (1,500 OCPU-hours + 9,000 GB-hours/month = 2/12 running continuously) and the full 200 GB combined boot/block-storage allowance (100 GB boot + 100 GB Docker data). The separate reserved public IPv4 keeps DNS stable across replacements; Oracle's Always Free page does not count it against these compute or storage allowances. An arm64 Ubuntu image is required. Do not add a third volume without reviewing the Always Free storage cap.
# A 500 "Out of host capacity" error is not retried by the OCI provider, even with a retries_config_file. Change local.oci_availability_domain_index to another AD and apply again, or wait and retry later; retry tuning cannot create host capacity.
# The first E2-to-A1 migration must be planned with -replace=oci_core_instance.a1_flex because the provider otherwise proposes an invalid in-place cross-architecture update.
# Rebuilds are deliberate only: use `terraform apply -replace=oci_core_instance.a1_flex` after reviewing the plan. `ignore_changes` hides cloud-init template drift because runcmd executes only on first boot; new instances still receive the current template at creation time. This also covers `ssh_authorized_keys`, so rotate keys directly in `authorized_keys` on the box rather than re-applying Terraform.
# The rebuild preserves `oci_core_volume.docker_data` because it is `prevent_destroy` and carries Docker data, the Postgres volume, and `/mnt/data/nba-env/.env`. The reserved public IP is retained, so DNS does not change. The 100 GB boot volume is destroyed, taking `/opt/nba` and host configuration; cloud-init recreates those on the replacement.
# `create_before_destroy` is intentionally omitted: this VM consumes the full Always Free A1 allowance of 1,500 OCPU-hours and 9,000 GB-hours (2 OCPUs and 12 GB continuously), so a second instance would exceed the allowance, and the non-shareable data volume cannot attach to both instances. Rebuilds therefore destroy then create and have a few minutes of downtime.
resource "oci_core_instance" "a1_flex" {
  availability_domain  = local.oci_availability_domain
  compartment_id       = var.oci_compartment_ocid
  display_name         = "oci-always-free-a1-flex"
  freeform_tags        = local.oci_freeform_tags
  preserve_boot_volume = false
  shape                = "VM.Standard.A1.Flex"

  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
  }

  create_vnic_details {
    # A reserved public IP cannot attach while this private IP has an ephemeral address.
    assign_public_ip = false
    display_name     = "oci-always-free-a1-flex-vnic"
    freeform_tags    = local.oci_freeform_tags
    subnet_id        = oci_core_subnet.public.id
  }

  metadata = {
    ssh_authorized_keys = trimspace(var.oci_ssh_public_key)
    user_data           = local.oci_cloud_init
  }

  source_details {
    boot_volume_size_in_gbs = 100
    boot_volume_vpus_per_gb = 10
    source_id               = local.oci_ubuntu_image_id
    source_type             = "image"
  }

  lifecycle {
    # Upstream image publication and first-boot-only cloud-init values must not silently replace the VM; roll an image or template intentionally with -replace=oci_core_instance.a1_flex.
    ignore_changes = [
      source_details[0].source_id,
      metadata,
    ]
  }
}

# Always Free networking: discovers the A1 instance's primary VNIC so the reserved public IP can follow an intentional instance replacement.
data "oci_core_vnic_attachments" "a1_flex" {
  compartment_id = var.oci_compartment_ocid
  instance_id    = oci_core_instance.a1_flex.id
}

# Always Free networking: discovers the primary private IP behind the A1 VNIC; this is a Terraform lookup and creates no OCI resource.
data "oci_core_private_ips" "a1_flex" {
  vnic_id = data.oci_core_vnic_attachments.a1_flex.vnic_attachments[0].vnic_id
}

# Always Free networking: reserves one public IPv4 address so the Cloudflare baseline A record survives instance replacement.
resource "oci_core_public_ip" "a1_flex" {
  compartment_id = var.oci_compartment_ocid
  display_name   = "oci-always-free-a1-flex-reserved-ip"
  freeform_tags  = local.oci_freeform_tags
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.a1_flex.private_ips[0].id
}

# Always Free storage: creates the 100 GB Docker/Postgres data volume; with the 100 GB boot volume this uses the full 200 GB allowance, so it must not be destroyed during routine instance replacement.
resource "oci_core_volume" "docker_data" {
  availability_domain = local.oci_availability_domain
  compartment_id      = var.oci_compartment_ocid
  display_name        = "oci-always-free-a1-flex-docker-data"
  freeform_tags       = local.oci_freeform_tags
  size_in_gbs         = 100

  lifecycle {
    prevent_destroy = true
  }
}

# Always Free storage: attaches the protected 100 GB data volume without an iSCSI login sequence in cloud-init.
resource "oci_core_volume_attachment" "docker_data" {
  attachment_type = "paravirtualized"
  device          = "/dev/oracleoci/oraclevdb"
  instance_id     = oci_core_instance.a1_flex.id
  volume_id       = oci_core_volume.docker_data.id
}
