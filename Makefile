.PHONY: help
.DEFAULT_GOAL := help

## List all available targets
help:
	@echo "\033[33mAvailable targets:\033[0m"
	@sed -E '$$!N;s/^## (.+)\n([^ :]+):.*$$/\2: ## \1/p;D' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m#####%s\n", $$1, $$2}' | column -t -s '#####'
	@echo ""

## Restart local dev container
dev/restart:
	@make dev/stop
	@make dev/start

## Initialize and setup the local dev environment
dev/setup:
	docker compose up --build -d

## Shell into the running local dev container (see `dev/setup`)
dev/sh:
	docker compose exec -it dev_sak /bin/bash --login

## Start local dev container
dev/start:
	docker compose up -d

## Stop and remove the running local dev container
dev/stop:
	docker compose down

## Terraform Cloud: Initialize configuration
tfcloud/config:
	@./bin/terraformrc_config.sh
