# resource "aws_kms_key" "terraform_sops_key" {
#   description             = "KMS key for SOPS secrets encryption"
#   deletion_window_in_days = 10
#   enable_key_rotation     = true

# }

# resource "aws_kms_alias" "terraform_sops_key_alias" {
#   name          = "alias/sops"
#   target_key_id = aws_kms_key.terraform_sops_key.key_id
# }

# Output the ARN to use with SOPS
# output "sops_kms_arn" {
#   value       = aws_kms_key.terraform_sops_key.arn
#   description = "ARN of the KMS key for SOPS encryption"
#   sensitive   = true
# }

# resources are read-only and dont get removed from state even if commented out
# and run terraform apply. have to manually run terraform state rm to remove them
# this yml file is encrypted using sops + the above kms key
# data "sops_file" "secrets" {
#   source_file = "secrets.enc.yaml"
# }

# resource "aws_ssm_parameter" "db_password" {
#   name  = "/prod/db/password"
#   type  = "SecureString"
#   value = data.sops_file.secrets.data["db_password"]
# }
