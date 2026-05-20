# Terraform Project

![Test Pipeline](https://github.com/jyablonski/aws_terraform/actions/workflows/test.yml/badge.svg) ![Deploy Pipeline](https://github.com/jyablonski/aws_terraform/actions/workflows/deploy.yml/badge.svg)

Terraform repo for personal infrastructure, experiments, and the AWS resources that support related application projects. It manages AWS account setup, Identity Center access, networking, ECS/ECR, Lambda, API Gateway, S3, RDS/PostgreSQL, Snowflake resources, observability integrations, and supporting IAM.

Terraform Cloud is configured for the `jyablonski_prac` organization and the `github-terraform-demo` workspace. AWS Organizations and AWS Identity Center are used to manage SSO access.

- This can easily be replaced with local Terraform usage and remote state backend in S3, I'm just lazy.

Reusable Terraform modules live in `modules/` for resources such as:

- GitHub Actions IAM roles
- Lambda functions
- PostgreSQL databases, roles, and schemas
- Snowflake databases, schemas, roles, stages, pipes, and warehouses
- S3 buckets
- ECS services
- CloudWatch alarms

## Local Workflow

Install Terraform and authenticate to the configured Terraform Cloud workspace before running plans locally.

```bash
make plan
```

The `make plan` command runs `terraform plan` from the repository root. Use it before opening a PR to preview infrastructure changes with the same Terraform configuration that CI uses.

Other Makefile targets:

- `make apply` runs `terraform apply --auto-approve`.
- `make sops` encrypts `secrets.yaml` into `secrets.enc.yaml` for CI/CD usage.
