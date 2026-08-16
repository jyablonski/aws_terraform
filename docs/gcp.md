# GCP Terraform Infrastructure

This repository manages the existing NBA dashboard VM, its reserved public IP, and a project-scoped monthly billing alert in Google Cloud. These resources share the root Terraform configuration and S3 state with the AWS and OCI infrastructure.

## Architecture

```text
GitHub Actions or local ADC
          |
          v
Terraform Google provider
          |
          +-- reserved address 34.83.137.138
          |          |
          |          +-- attached to nba-dashboard-vm
          |          |
          |          +-- used by Cloudflare A records for nbadashboard and mcp
          |
          +-- $5 monthly GCP budget alert
```

The Google provider defaults to project `nba-dashboard-467120`, region `us-west1`, and zone `us-west1-a`. Terraform state remains in the repository's existing encrypted S3 backend; there is no separate GCP state or GCS backend.

## Terraform-managed resources

The GCP declarations live in `gcp.tf`.

| Terraform address | GCP resource | Purpose |
| --- | --- | --- |
| `google_compute_address.dashboard` | `nba-dashboard-vm-ip` | Preserves the premium-tier regional IPv4 address `34.83.137.138` so DNS does not change when the VM restarts or is replaced intentionally. |
| `google_compute_instance.nba_dashboard` | `nba-dashboard-vm` | Runs the existing dashboard workloads on an `e2-micro` Debian 12 VM with a 10 GB balanced persistent boot disk. |
| `google_billing_budget.monthly_five_dollar_alert` | `NBA dashboard monthly $5 alert` | Sends an alert when actual monthly project spend reaches 100% of the $5 USD budget. |

The VM uses the default VPC and `us-west1` subnet, attaches the reserved address, and keeps the existing `http-server` and `https-server` network tags. Its existing regional schedule policy and default Compute Engine service account are referenced by the resource but are not managed here.

`dashboard.tf` exposes the reserved address as `local.dashboard_vm_ip`. The `nbadashboard.jyablonski.dev` and `mcp.jyablonski.dev` Cloudflare A records consume that local with a 300-second TTL. Both records are DNS-only because proxy buffering interferes with the MCP server's SSE traffic.

The VM and address have Terraform `prevent_destroy` lifecycle rules. The budget uses both `deletion_policy = "PREVENT"` and `prevent_destroy`. Any change that requires replacement will therefore fail at plan or apply until the protection is deliberately reviewed and removed.

## Imported resources and ownership boundary

The VM and reserved address existed before their Terraform declarations and were imported into the shared root state once:

```bash
terraform import google_compute_address.dashboard projects/nba-dashboard-467120/regions/us-west1/addresses/nba-dashboard-vm-ip
terraform import google_compute_instance.nba_dashboard projects/nba-dashboard-467120/zones/us-west1-a/instances/nba-dashboard-vm
```

Do not rerun these imports while the resources remain in state. The imported configuration intentionally preserves existing details such as the boot image, SSH metadata, schedule policy, service account scopes, and network settings to avoid an unexpected VM replacement.

The following bootstrap resources remain outside this root Terraform state:

- The GCP project, billing-account link, and enabled Google APIs.
- The default VPC, subnet, relevant firewall rules, and `default-schedule-1` resource policy.
- The VM's default Compute Engine service account.
- The Terraform plan/deploy service accounts, Workload Identity Pool/provider, custom budget roles, and their IAM bindings.

## Local authentication

Local Terraform uses Google Application Default Credentials (ADC), not a downloaded service-account key:

```bash
gcloud auth login
gcloud config set project nba-dashboard-467120
gcloud auth application-default login
gcloud auth application-default set-quota-project nba-dashboard-467120
```

The ADC file is stored by `gcloud` under `~/.config/gcloud/application_default_credentials.json` and must never be committed. The provider's `billing_project` and `user_project_override` settings route service usage and quota accounting through `nba-dashboard-467120`; the CI identities therefore have `roles/serviceusage.serviceUsageConsumer`. `add_terraform_attribution_label = false` prevents the provider from adding a label to the imported VM and creating drift from its existing configuration.

Check the active local identity and project before planning:

```bash
gcloud auth list
gcloud config get-value project
terraform plan
```

## GitHub Actions authentication

The pull-request and deploy jobs in `.github/workflows/ci_cd.yaml` use `google-github-actions/auth@v3` with GitHub's OpenID Connect token. Google Workload Identity Federation exchanges that short-lived token for Google credentials, so the repository does not store a GCP JSON key.

The active provider is:

```text
projects/96770708928/locations/global/workloadIdentityPools/github/providers/aws-terraform
```

It accepts assertions only when `assertion.repository == 'jyablonski/aws_terraform'`. The service-account bindings add a second boundary:

| Workflow | Service account | Federation boundary | Project roles |
| --- | --- | --- | --- |
| Pull-request plan | `terraform-plan@nba-dashboard-467120.iam.gserviceaccount.com` | Any ref from `jyablonski/aws_terraform`; the workflow itself runs only for pull requests. | Compute Viewer, Service Usage Consumer, and the custom Terraform Budget Viewer role. |
| Master deploy | `terraform-deploy@nba-dashboard-467120.iam.gserviceaccount.com` | `refs/heads/master` only. | Compute Instance Admin, Compute Network Admin, Service Usage Consumer, and the custom Terraform Budget Manager role. |

The custom budget roles keep budget access project-scoped instead of granting access across the entire billing account:

| Custom role | Permissions |
| --- | --- |
| `terraformBudgetViewer` | `billing.resourcebudgets.read`, `resourcemanager.projects.get` |
| `terraformBudgetManager` | `billing.resourcebudgets.read`, `billing.resourcebudgets.write`, `resourcemanager.projects.get` |

Because this is one root configuration, both jobs also need working credentials for every other provider Terraform refreshes, including AWS, OCI, Cloudflare, and PostgreSQL. GCP authentication alone is not enough to run the complete root plan.

## Billing alert behavior

The budget applies only to project number `96770708928`, resets every calendar month, and compares the $5 threshold with current actual spend after all credits are included. It has one threshold rule at `1.0`, meaning notification begins after recorded spend reaches 100% of the budget.

Default billing IAM recipients remain enabled, and project-level recipients are enabled so eligible project owners can receive the email. No Cloud Monitoring notification channel or Pub/Sub automation is configured.

A GCP budget is an alert, not a spending cap. It does not stop the VM or prevent new resources, and cost reporting plus email delivery can lag behind actual usage. Review the Billing console when an alert arrives rather than treating $5 as a hard maximum.
