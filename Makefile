.PHONY: plan
plan:
	@terraform plan

.PHONY: apply
apply:
	@terraform apply --auto-approve

# Encrypt local Terraform variables into the SOPS file used by CI/CD.
# The age private key is read from SOPS_AGE_KEY_FILE, defaulting to the
# ignored local key file generated for this repo.
.PHONY: sops
sops:
	@SOPS_AGE_KEY_FILE=$${SOPS_AGE_KEY_FILE:-.sops-age-key.txt} sops --encrypt --input-type binary --output-type yaml --output secrets.enc.yaml terraform.tfvars

# Decrypt secrets.enc.yaml and confirm it matches local terraform.tfvars.
.PHONY: sops-verify
sops-verify:
	@SOPS_AGE_KEY_FILE=$${SOPS_AGE_KEY_FILE:-.sops-age-key.txt} \
		sops exec-file --output-type binary --filename terraform.tfvars secrets.enc.yaml \
		'cmp -s {} terraform.tfvars' \
	|| (echo "secrets.enc.yaml does not match terraform.tfvars (run make sops after editing tfvars)" >&2; exit 1)
	@echo "secrets.enc.yaml matches terraform.tfvars"

# Print decrypted terraform.tfvars from secrets.enc.yaml (writes secrets to the terminal).
.PHONY: sops-view
sops-view:
	@SOPS_AGE_KEY_FILE=$${SOPS_AGE_KEY_FILE:-.sops-age-key.txt} \
		sops exec-file --output-type binary --filename terraform.tfvars secrets.enc.yaml 'cat {}'
