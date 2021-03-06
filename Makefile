# Using bash
SHELL := /bin/bash

# One worker at the time
MAKEFLAGS = --jobs=1

.PHONY: init
init: ## 配置開發環境的相關套件
	pip3 install pre-commit
	pre-commit install

.PHONY: clean
clean: ## 清理 tgz 檔案
	find . -name "*.tgz" -delete

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help
