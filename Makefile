# use this after successful pull request to grab new version and sync both branches
PHONY: git-rebase
git-rebase:
	@git checkout master
	@git pull
	@git checkout feature_integration
	@git rebase master
	@git push

.PHONY: bump-patch
bump-patch:
	@bump2version patch
	@git push --tags
	@git push

.PHONY: bump-minor
bump-minor:
	@bump2version minor
	@git push --tags
	@git push

.PHONY: bump-major
bump-major:
	@bump2version major
	@git push --tags
	@git push

.PHONY: docs
docs:
	@terraform-docs markdown table --output-file tf_docs.md --output-mode inject ./

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
