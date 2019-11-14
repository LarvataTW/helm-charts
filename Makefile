# Using bash
SHELL := /bin/bash

# One worker at the time
MAKEFLAGS = --jobs=1

# Chart directories
CHARTS = $(shell ls -d */)
TGZ_DIR = /tmp/charts/

.PHONY: init
init: ## 配置開發環境的相關套件
	pip3 install pre-commit
	pre-commit install

.PHONY: dependency
dependency: ## 取得相依的 Charts
	@$(foreach chart,$(CHARTS),cd $(chart) && helm dependency update && cd ..;)
	@$(foreach chart,$(CHARTS),cd $(chart) && helm dependency build && cd ..;)

.PHONY: package
package: ## 打包各個 Chart
	$(MAKE) dependency
	mkdir -p $(TGZ_DIR)
	@$(foreach chart,$(CHARTS),cd $(chart) && helm package . -d $(TGZ_DIR) && cd ..;)

.PHONY: release
release: ## 更新 Github Page
	$(MAKE) package
	git checkout gh-pages
	git clean -f -d .
	mv -v $(TGZ_DIR)/*tgz .
	helm repo index . --url https://larvatatw.github.io/helm-charts/
	git add -f *.tgz index.yaml
	git commit -m "release: $(shell date)"
	git push --set-upstream origin gh-pages
	git checkout master
	$(MAKE) clean
	helm repo update

.PHONY: clean
clean: ## 清理 tgz 檔案
	find . -name "*.tgz" -delete

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help
