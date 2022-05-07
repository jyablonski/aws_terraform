locals {
  glue_catalog_db_name             = "jacobs_glue_catalog_database"
  glue_catalog_table_name_injuries = "jacobs_catalog_table_injuries"
}

# so you have a generic "database" which is like a "cluster" in ecs.  you dont do anything with it but put other connections inside of it.
# you then have tables inside the database where you define the schema of what's inside the table - either manually or via their crawler process.
# connections are for how to access the data source - like s3 or SQL or if it's in another account or something.
# schema registry which houses schemas for json/avro/grpc schemas.
# i got the parquet table working, some columns won't map correctly but you can query the others in athena.

resource "aws_glue_catalog_database" "aws_glue_catalog_database_test" {
  name = local.glue_catalog_db_name
}

resource "aws_glue_catalog_table" "aws_glue_catalog_table_injuries" {
  name          = local.glue_catalog_table_name_injuries
  database_name = aws_glue_catalog_database.aws_glue_catalog_database_test.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    # EXTERNAL              = "TRUE"
    # "parquet.compression" = "SNAPPY"
    classification = "parquet"
  }

  storage_descriptor {
    location      = "s3://jacobsbucket97/injury_data/validated/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }

    columns {
      name = "player"
      type = "string"
    }

    columns {
      name = "team"
      type = "string"
    }

    # this col is fucked, it's saved as binary or some shit and wont take date/timestamp idfk dude. grats on using athena this thing blows
    columns {
      name    = "date"
      type    = "date"
      comment = "timestamp w/o time zone"
    }

    columns {
      name = "description"
      type = "string"
    }

    columns {
      name    = "scrape_date"
      type    = "date"
      comment = "raw date in yyyy-mm-dd format"
    }
  }
}