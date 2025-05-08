terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "1.0.5"
    }


  }
}

# query accel - snowflake enterprise edition feature used if you have unpredicatable workloads on a warehouse
# it will offload parts of outlier queries to a set of snowflake-managed compute resources to help improve performance

# a warehouse basically always has a min and max cluster of 1.  this doesn't mean it's on 24/7, it just means it scales to a max of 1
# and can still spin down to 0
resource "snowflake_warehouse" "this" {
  name                                = var.warehouse_name
  comment                             = var.warehouse_comment
  warehouse_size                      = var.warehouse_size
  enable_query_acceleration           = false
  query_acceleration_max_scale_factor = null

  statement_timeout_in_seconds = var.statement_timeout
  auto_resume                  = true
  auto_suspend                 = 180
  initially_suspended          = true

  # min_cluster_count = var.min_cluster_count == 1 ? 1 : var.min_cluster_count
  # max_cluster_count = var.max_cluster_count == 1 ? 1 : var.max_cluster_count
  # scaling_policy    = var.warehouse_scaling_policy == "" ? "STANDARD" : var.warehouse_scaling_policy
}

resource "snowflake_grant_privileges_to_account_role" "this" {
  for_each = toset(var.role_names)

  account_role_name = each.value
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this.name
  }

  with_grant_option = false
}
