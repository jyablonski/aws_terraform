# OCI Free-Tier Setup — Session Summary

**Date:** 2026-08-15
**Workstation:** Arch Linux
**Goal:** Move a sub-$5/mo Docker VM to $0 by hosting on Oracle Cloud Always Free. Postgres stays on Aiven free tier.

---

## 1. Why Oracle

| Provider             | Always-free VM?                                         | Verdict          |
| -------------------- | ------------------------------------------------------- | ---------------- |
| **OCI**              | 2× AMD micro (1 GB each) + ARM A1 pool (2 OCPU / 12 GB) | **Chosen**       |
| GCP                  | 1× e2-micro, 1 GB, US regions only                      | Backup / standby |
| AWS                  | None — credit-based since 2025-07-15                    | Ruled out        |
| Azure                | B1s is 12-month only                                    | Ruled out        |
| Render / Koyeb / Fly | Sleeps, 512 MB, or gone                                 | Ruled out        |

**Free-tier allowance as of June 2026** (halved from 4 OCPU / 24 GB on 2026-06-15, enforced 2026-08-18):

- 2× `VM.Standard.E2.1.Micro` — x86_64, 1/8 OCPU, **1 GB RAM each**, fixed shape, single AD only
- `VM.Standard.A1.Flex` — arm64, **2 OCPU + 12 GB RAM total**, splittable into 1–2 instances
- 200 GB block storage, min 47 GB boot volume per instance
- 10 TB/mo egress, 1 Flexible LB (10 Mbps), 1 Network LB

**Kubernetes is viable for $0** — OKE Basic clusters have no control-plane fee; only worker nodes bill, and A1 nodes are free. Alternative: k3s on a single 12 GB A1 (more allocatable memory, no OKE lock-in).

---

## 2. Tooling installed

```bash
sudo pacman -S uv
uv tool install oci-cli          # not pipx — uv manages its own Python,
                                 # avoids Arch's bleeding-edge Python vs
                                 # Oracle's pinned deps
pacman -Ss '^terraform$' '^opentofu$'   # opentofu is the MPL fork; drop-in
```

Optional, for arm64 cross-builds if moving to A1:
`docker docker-buildx qemu-user-static qemu-user-static-binfmt`

---

## 3. Commands run

```bash
# Auth bootstrap — generated RSA API key, wrote ~/.oci/config
oci setup config
#   config path:  ~/.oci/config (default)
#   user OCID:    from Console → avatar → My profile
#   tenancy OCID: from Console → Administration → Tenancy details
#   region:       us-phoenix-1
#   new keypair:  Y, no passphrase

# Registered public key in Console → My profile → API keys → Add API key
cat ~/.oci/oci_api_key_public.pem

# Verified auth
oci iam region list --output table          # ✅
oci iam availability-domain list --output table
oci os ns get

# Created compartment
oci iam compartment create \
  --compartment-id <tenancy-ocid> \
  --name sandbox \
  --description "Terraform-managed free tier resources"

# Instance SSH key (separate from API key)
ssh-keygen -t ed25519 -f ~/.ssh/oci_sandbox -C "oci-sandbox"
```

**Note:** one `401 NotAuthenticated` on `availability-domain list` immediately after key upload. Transient — API key propagation lag. Resolved on retry ~1 min later. If it recurs persistently, check clock skew (`timedatectl`) before suspecting the key.

---

## 4. Two keypairs — don't conflate

| Key                    | Local source              | Purpose                                                                 |
| ---------------------- | ------------------------- | ----------------------------------------------------------------------- |
| API signing (RSA)      | `~/.oci/oci_api_key.pem`  | Authenticates Terraform to the OCI control plane; encrypted with SOPS   |
| Instance SSH (ed25519) | `~/.ssh/oci_sandbox`      | Shell access *to* the VM once it exists; only its public key is in SOPS |

---

## 5. Values for Terraform

```hcl
oci_tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaae3nzzf23igrfpmg6jhgdv2dmxuc6uftjpleio73b2fpiuajmmhgq"
oci_compartment_ocid = "ocid1.compartment.oc1..aaaaaaaaaj4m3eqzamk3h3zdc4z4ledxs5or6fnwigs6nconmbimba5lyoka"
oci_region           = "us-phoenix-1"
oci_ssh_public_key   = "<contents of ~/.ssh/oci_sandbox.pub>"
oci_user_ocid        = "<OCI API user OCID>"
oci_fingerprint      = "<OCI API signing key fingerprint>"
oci_private_key      = <<EOT
<contents of ~/.oci/oci_api_key.pem>
EOT
```

| Item                     | Value                                             |
| ------------------------ | ------------------------------------------------- |
| Tenancy name             | `jyablonski9`                                     |
| Home region              | `us-phoenix-1` (PHX)                              |
| Availability domains     | `oymf:PHX-AD-1`, `oymf:PHX-AD-2`, `oymf:PHX-AD-3` |
| Object storage namespace | `axwilvlaq9no`                                    |

Keep the API user OCID, fingerprint, and private key only in the gitignored `terraform.tfvars` and its SOPS-encrypted `secrets.enc.yaml` representation. Never put their literal values in `.tf` source files. The provider accepts the decrypted values directly:

```hcl
provider "oci" {
  auth         = "ApiKey"
  fingerprint  = var.oci_fingerprint
  private_key  = var.oci_private_key
  region       = var.oci_region
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
}
```

GitHub Actions already decrypts `secrets.enc.yaml` into a temporary `terraform.tfvars` for plan and apply. OCI therefore uses the same inputs locally and in CI, and the runner does not need `~/.oci/config` or a separate OCI GitHub secret. The existing `SOPS_AGE_KEY` GitHub secret is the only key needed to unlock the payload.

---

## 6. Ownership boundary

| Manual / CLI                                    | Terraform                                                 |
| ----------------------------------------------- | --------------------------------------------------------- |
| OCI API key registration                        | VCN, subnet, internet gateway, route table, security list |
| Compartment (`terraform`) — can't be hard-deleted | **Compute instance** + cloud-init                       |
| SSH keypair                                     | Boot / block volumes                                      |
| Quota policy — see below                        | Budget, load balancer, OKE cluster (later)                |

Budgets must be created in the tenancy **root** compartment even when targeting a child. Quotas matter more than budgets — budgets only notify (with lag), quotas actually refuse to provision. Build the quota statement in the Console policy builder first, verify it blocks a paid shape, then transcribe to HCL.

Provider is `oracle/oci` (~> 8.0). **Not** `hashicorp/oci` — that namespace is deprecated.

---

## 7. Remaining to-do

- [ ] Capacity probe across all three ADs (which offer A1 / E2.1.Micro)
- [ ] Optional budget email alert rule + quota policy — **before first apply**
- [x] Use the repository's existing S3 backend and shared root state
- [ ] Write HCL, `terraform init && plan`
- [ ] Plan review: shape correct, boot volume 47–50 GB, **no `oci_core_public_ip`** (reserved IPs bill when detached)
- [ ] Migrate services, verify $0 in billing, delete old paid VM

---

## 8. Risks

- **Oracle rug-pull risk.** The June 2026 halving shipped with no announcement — docs were silently edited and instances terminated. Keep everything in Terraform, keep offsite backups, treat migration to a €4/mo Hetzner box as a one-afternoon job.
- **Idle reclamation.** Always Free accounts only: instances are stopped if 95th-pct CPU, network, *and* memory (A1 only) all stay under 20% for 7 days. **Upgrading to PAYG exempts you** and still costs $0 within the free envelope — but removes the hard spend ceiling, hence the quota policy.
- **A1 capacity.** "Out of host capacity" is common; retry across ADs. PAYG improves odds considerably.
- **arm64.** A1 requires arm64 images. Most official Docker Hub images are multi-arch; audit your compose file before committing.
- **E2.1.Micro is single-AD.** Which AD varies by tenancy — try all three before assuming breakage.
