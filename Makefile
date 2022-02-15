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

.PHONY: bump-minor
bump-minor:
	@bump2version minor

.PHONY: bump-major
bump-major:
	@bump2version major