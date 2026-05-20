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
