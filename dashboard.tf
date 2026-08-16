locals {
  dashboard_vm_ip   = google_compute_address.dashboard.address
  dashboard_dns_ttl = 300
}
