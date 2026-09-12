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
