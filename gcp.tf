resource "google_compute_address" "dashboard" {
  address      = "34.83.137.138"
  address_type = "EXTERNAL"
  name         = "nba-dashboard-vm-ip"
  network_tier = "PREMIUM"
  project      = "nba-dashboard-467120"
  region       = "us-west1"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_billing_budget" "monthly_five_dollar_alert" {
  billing_account = "01AAF4-49BB23-7BFCA7"
  deletion_policy = "PREVENT"
  display_name    = "NBA dashboard monthly $5 alert"
  budget_filter {
    calendar_period        = "MONTH"
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
    projects               = ["projects/96770708928"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = "5"
    }
  }

  threshold_rules {
    spend_basis       = "CURRENT_SPEND"
    threshold_percent = 1.0
  }

  all_updates_rule {
    disable_default_iam_recipients   = false
    enable_project_level_recipients  = true
    monitoring_notification_channels = []
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_instance" "nba_dashboard" {
  enable_display             = false
  key_revocation_action_type = "NONE"
  labels                     = {}
  machine_type               = "e2-micro"
  name                       = "nba-dashboard-vm"
  project                    = "nba-dashboard-467120"
  resource_policies          = []
  tags                       = ["http-server", "https-server"]
  zone                       = "us-west1-a"

  # these are public keys mfer
  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys = join("\n", [
      "jyablonski9:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII+6E4yE63HmvMerI1J85WJtfmKMPZZiKUnuqsS8jgT6 jyablonski9@arch",
      "jyablonski9:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOSvyH5PCa6qzqNWm59uzVjtitmqDcmehYf7Oegpu5YM+CNbz0FsqWslSQvhJ3WTs1w8GDgVX6VGecEhQ4I/fSA= google-ssh {\"userName\":\"jyablonski9@gmail.com\",\"expireOn\":\"2026-06-06T22:52:41+0000\"}",
      "jyablonski9:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAHyLSF2fCA3c350hle+w6Lk5I0QVmtHypTDzzI/COTzOxt7KDxfWlvMsT8A59gatB+kQMpnQJmDL87eJ/29Yrs46gjLpRWisP73a4c8Rl5ykEhoML9SH3vVUJjSTWJLnC6NwXtES0lZ8hrKL8bmT5zxINg6kvGH6Mjdymyl0tzPFA7y1dXpyshmsYHsxtNpsG/4UqTrUQprbze4250tayopZRDlmOUMI2J5bClbmyoJMw65qAvxRcAuqU89aqaH6JnL2qjX9XXdBDn8G68h0jrxHW+LTFLPwox6p7/3SCl9tBdCjB9QFcjmhMjx/RTugYJOw4fiU5jegsxI2Pivh9nk= google-ssh {\"userName\":\"jyablonski9@gmail.com\",\"expireOn\":\"2026-06-06T22:52:44+0000\"}",
    ])
  }

  boot_disk {
    auto_delete  = true
    device_name  = "nba-dashboard-vm"
    force_attach = false
    mode         = "READ_WRITE"

    initialize_params {
      architecture                = "X86_64"
      enable_confidential_compute = false
      image                       = "https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/debian-12-bookworm-v20250709"
      resource_policies           = ["https://www.googleapis.com/compute/v1/projects/nba-dashboard-467120/regions/us-west1/resourcePolicies/default-schedule-1"]
      size                        = 10
      type                        = "pd-balanced"
    }
  }

  confidential_instance_config {
    enable_confidential_compute = false
  }

  network_interface {
    network            = "https://www.googleapis.com/compute/v1/projects/nba-dashboard-467120/global/networks/default"
    stack_type         = "IPV4_ONLY"
    subnetwork         = "https://www.googleapis.com/compute/v1/projects/nba-dashboard-467120/regions/us-west1/subnetworks/default"
    subnetwork_project = "nba-dashboard-467120"

    access_config {
      nat_ip       = google_compute_address.dashboard.address
      network_tier = "PREMIUM"
    }
  }

  reservation_affinity {
    type = "ANY_RESERVATION"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email = "96770708928-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
