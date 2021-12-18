# use this when on feature_integration to rebase feature integration w/ the lint changes applied to master after accepting a mr
PHONY: git-rebase
git-rebase:
	git rebase origin/master