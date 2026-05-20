# Terraform Project

![Test Pipeline](https://github.com/jyablonski/aws_terraform/actions/workflows/test.yml/badge.svg) ![Deploy Pipeline](https://github.com/jyablonski/aws_terraform/actions/workflows/deploy.yml/badge.svg)

Terraform repo for personal infrastructure, experiments, and the AWS resources that support related application projects. It manages AWS account setup, Identity Center access, networking, ECS/ECR, Lambda, API Gateway, S3, RDS/PostgreSQL, Snowflake resources, observability integrations, and supporting IAM.

Terraform state is stored in an S3 backend with S3-native lockfiles. AWS Organizations and AWS Identity Center are used to manage SSO access.

Reusable Terraform modules live in `modules/` for resources such as:

- GitHub Actions IAM roles
- Lambda functions
- PostgreSQL databases, roles, and schemas
- Snowflake databases, schemas, roles, stages, pipes, and warehouses
- S3 buckets
- ECS services
- CloudWatch alarms

## Local Workflow

Install Terraform and authenticate to AWS before running plans locally. Terraform automatically reads the local `terraform.tfvars` file when it exists.

```bash
make plan
```

The `make plan` command runs `terraform plan` from the repository root. Use it before opening a PR to preview infrastructure changes with the same Terraform configuration that CI uses.

Other Makefile targets:

- `make apply` runs `terraform apply --auto-approve`.
- `make sops` encrypts `terraform.tfvars` into the age-backed `secrets.enc.yaml` file used by CI/CD. The age private key is kept out of git locally and stored in GitHub Actions as `SOPS_AGE_KEY`.

Secrets are managed with SOPS and age. `secrets.enc.yaml` stores the entire `terraform.tfvars` file as one encrypted payload, which keeps Terraform variable parsing identical locally and in CI. The tradeoff is less readable diffs, but the setup is simple and avoids a paid KMS key.
