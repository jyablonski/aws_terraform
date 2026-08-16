# Terraform Project

![Terraform Pipeline](https://github.com/jyablonski/aws_terraform/actions/workflows/ci_cd.yaml/badge.svg)

Terraform repo for personal infrastructure and experiments across AWS and Oracle Cloud Infrastructure. It manages AWS account setup, Identity Center access, networking, ECS/ECR, Lambda, API Gateway, S3, RDS/PostgreSQL, Snowflake resources, observability integrations, supporting IAM, and an OCI Always Free sandbox.

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

- `make test` runs Terraform's native module tests under `modules/**/tests/*.tftest.hcl`. These tests are plan-level and use mocked providers; the test runner refuses `command = apply` tests by default so it does not create real resources. On a fresh machine or CI runner, use `TERRAFORM_TEST_INIT=1 make test` to initialize each tested module before running tests. Module tests run concurrently; set `TERRAFORM_TEST_JOBS=8` to change the worker count or `TERRAFORM_TEST_VERBOSE=1` to print every module log.
- `make apply` runs `terraform apply --auto-approve`.
- `make sops` encrypts `terraform.tfvars` into the age-backed `secrets.enc.yaml` file used by CI/CD. The age private key is kept out of git locally and stored in GitHub Actions as `SOPS_AGE_KEY`.
- `make sops-verify` decrypts `secrets.enc.yaml` and checks that it matches local `terraform.tfvars`.
- `make sops-view` prints the decrypted `terraform.tfvars` from `secrets.enc.yaml`.

Secrets are managed with SOPS and age. `secrets.enc.yaml` stores the entire `terraform.tfvars` file as one encrypted payload, which keeps Terraform variable parsing identical locally and in CI. The tradeoff is less readable diffs, but the setup is simple and avoids a paid KMS key.

## OCI authentication

OCI resources are part of this same root configuration and state. Terraform reads OCI API-key credentials from the `DEFAULT` profile in `~/.oci/config`; no OCI API credential fields belong in Terraform variables. The only OCI inputs are `oci_tenancy_ocid`, `oci_compartment_ocid`, `oci_region`, and `oci_ssh_public_key`; their environment-variable equivalents use the `TF_VAR_` prefix.

The CI plan and deploy jobs now discover the OCI resources because they run Terraform from the repository root. Those jobs still require an OCI `DEFAULT` profile and its referenced private key on the runner before OCI plans or applies can succeed. The Terraform IAM group also needs `manage usage-budgets in tenancy` for the $1 monthly budget.
