resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.is_versioning_enabled
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    expiration {
      days = var.prefix_expiration_length
    }

    filter {
      prefix = var.prefix_expiration_name
    }

    id     = "${var.prefix_expiration_length}-day-removal"
    status = "Enabled"
  }

}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = var.bucket_acl
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" { # tflint-ignore: terraform_required_providers
  # tflint-ignore: terraform_required_providers
  #         "AWS": ["${join(",", var.s3_access_resources)}"]
  bucket = aws_s3_bucket.this.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${jsonencode(var.s3_access_resources)}
      },
      "Action": "s3:*",
      "Resource": [
        "${aws_s3_bucket.this.arn}/*",
        "${aws_s3_bucket.this.arn}"
      ]
    }
  ]
}
EOF

}