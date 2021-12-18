###################
#                 #
#    SNOWFLAKE    #
#                 #
###################

resource "snowflake_database" "NBA_ELT_DB" {
  name                        = "NBA_ELT_DB"
  data_retention_time_in_days = 0
}

resource "snowflake_schema" "NBA_AIRFLOW" {
  database = "NBA_ELT_DB"
  name     = "NBA_AIRFLOW"

  is_transient        = false
  is_managed          = true
  data_retention_days = 0
}

resource "snowflake_schema" "NBA_AIRFLOW_QA" {
  database = "NBA_ELT_DB"
  name     = "NBA_AIRFLOW_QA"

  is_transient        = false
  is_managed          = true
  data_retention_days = 0
}


resource "snowflake_schema" "TEST_SCHEMA" {
  database = "NBA_ELT_DB"
  name     = "TEST_SCHEMA"

  is_transient        = false
  is_managed          = true
  data_retention_days = 0
}
