output "s3_bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.this.id
}

