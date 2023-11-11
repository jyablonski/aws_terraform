locals {
  iceberg_user                   = "jyablonski-pyspark-iceberg-user"
  iceberg_iam_policy_description = "Policy for PySpark Iceburger Testing"
  iceberg_glue_database          = "nba_elt_iceberg"
}


module "iceberg_lake" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski2-iceberg"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 14
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

module "delta_lake" {
  source                   = "./modules/s3"
  bucket_name              = "jyablonski2-delta"
  bucket_acl               = "private"
  is_versioning_enabled    = "Disabled"
  prefix_expiration_name   = "*"
  prefix_expiration_length = 365
  s3_access_resources = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
}

resource "aws_iam_user" "jyablonski_pyspark_user" {
  name = local.iceberg_user

}

resource "aws_iam_policy" "jyablonski_pyspark_policy" {
  name        = "${local.iceberg_user}-policy"
  description = local.iceberg_iam_policy_description


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "glue:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          "${module.iceberg_lake.s3_bucket_arn}",
          "${module.iceberg_lake.s3_bucket_arn}/*",
          "${module.delta_lake.s3_bucket_arn}",
          "${module.delta_lake.s3_bucket_arn}/*"
        ]
      },
      {
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.jacobs_bucket_tf.arn}",
          "${aws_s3_bucket.jacobs_bucket_tf.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "jyablonski_pyspark_iceberg_attachment" {
  user       = aws_iam_user.jyablonski_pyspark_user.name
  policy_arn = aws_iam_policy.jyablonski_pyspark_policy.arn
}

resource "aws_glue_catalog_database" "pyspark" {
  name = local.iceberg_glue_database
}