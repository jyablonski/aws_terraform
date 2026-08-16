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
  oci_freeform_tags = {
    managed-by = "terraform"
    cost-scope = "oci-always-free"
  }

  oci_availability_domain = data.oci_identity_availability_domains.available.availability_domains[local.oci_availability_domain_index].name
  oci_ubuntu_arm64_images = [
    for image in data.oci_core_images.ubuntu_2404.images : image
    if strcontains(lower(image.display_name), "aarch64")
  ]
  oci_ubuntu_image_id = local.oci_ubuntu_arm64_images[0].id
  oci_cloud_init = base64encode(templatefile("${path.module}/templates/oci-cloud-init.yaml.tftpl", {
    default_user = "ubuntu"
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

# Always Free compute/storage/networking: consumes the full A1 allowance of 2 OCPUs and 12 GB RAM (0 A1 OCPUs/GB remain), 50 of 200 GB combined boot/block storage (150 GB remains), and 1 ephemeral public IPv4 address. An arm64 Ubuntu image is required. Provider 8.x documents 50 GB as the configurable boot-volume minimum.
# A 500 "Out of host capacity" error is not retried by the OCI provider, even with a retries_config_file. Change local.oci_availability_domain_index to another AD and apply again, or wait and retry later; retry tuning cannot create host capacity.
# The first E2-to-A1 migration must be planned with -replace=oci_core_instance.a1_flex because the provider otherwise proposes an invalid in-place cross-architecture update.
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
    assign_public_ip = true
    display_name     = "oci-always-free-a1-flex-vnic"
    freeform_tags    = local.oci_freeform_tags
    hostname_label   = "a1flex"
    subnet_id        = oci_core_subnet.public.id
  }

  metadata = {
    ssh_authorized_keys = trimspace(var.oci_ssh_public_key)
    user_data           = local.oci_cloud_init
  }

  source_details {
    boot_volume_size_in_gbs = 50
    boot_volume_vpus_per_gb = 10
    source_id               = local.oci_ubuntu_image_id
    source_type             = "image"
  }

  lifecycle {
    create_before_destroy = true
  }
}
