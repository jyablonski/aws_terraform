# query accel - snowflake enterprise edition feature used if you have unpredicatable workloads on a warehouse
# it will offload parts of outlier queries to a set of snowflake-managed compute resources to help improve performance

# a warehouse basically always has a min and max cluster of 1.  this doesn't mean it's on 24/7, it just means it scales to a max of 1
# and can still spin down to 0
resource "snowflake_warehouse" "this" {
  name                                = var.warehouse_name
  comment                             = var.warehouse_comment
  warehouse_size                      = var.warehouse_size
  enable_query_acceleration           = false
  query_acceleration_max_scale_factor = 0
  
  statement_timeout_in_seconds = var.statement_timeout
  auto_resume                  = true
  auto_suspend                 = 180
  initially_suspended          = true

  min_cluster_count = var.min_cluster_count == 1 ? 1 : var.min_cluster_count
  max_cluster_count = var.max_cluster_count == 1 ? 1 : var.max_cluster_count
  scaling_policy    = var.warehouse_scaling_policy == "" ? "STANDARD" : var.warehouse_scaling_policy
}

resource "snowsql_exec" "this_all" {
  for_each = toset(var.role_names)

  name = "${each.key}_warehouse_grant"

  create {
    statements = <<-EOT
    GRANT USAGE ON WAREHOUSE ${snowflake_warehouse.this.name} TO ROLE ${each.key};
    GRANT OPERATE ON WAREHOUSE ${snowflake_warehouse.this.name} TO ROLE ${each.key};
    EOT
  }

  delete {
    statements = <<-EOT
    REVOKE USAGE ON WAREHOUSE ${snowflake_warehouse.this.name} FROM ROLE ${each.key};
    REVOKE OPERATE ON WAREHOUSE ${snowflake_warehouse.this.name} FROM ROLE ${each.key};
    EOT
  }
}