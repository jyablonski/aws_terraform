# use this after successful pull request to grab new version and sync both branches
PHONY: git-rebase
git-rebase:
	@git checkout master
	@git pull
	@git checkout feature_integration
	@git rebase master
	@git push