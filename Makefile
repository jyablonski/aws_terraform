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