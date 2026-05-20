.PHONY: plan
plan:
	@terraform plan

.PHONY: apply
apply:
	@terraform apply --auto-approve

# this is used to encrypt secrets.yaml (plaintext secrets) into secrets.enc.yaml
# which can be stored in git and used in ci / cd to generate secrets. this works fine
# for 1-developer use, but for teams you could probably set up a helper command and
# store secrets.yaml in s3 or something
.PHONY: sops
sops:
	@sops -e secrets.yaml > secrets.enc.yaml
