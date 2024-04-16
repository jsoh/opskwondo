.PHONY: help
.DEFAULT_GOAL := help

## List all available targets
help:
	@echo "\033[33mAvailable targets:\033[0m"
	@sed -E '$$!N;s/^## (.+)\n([^ :]+):.*$$/\2: ## \1/p;D' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m#####%s\n", $$1, $$2}' | column -t -s '#####'
	@echo ""

## Build local dev container image
dev/build:
	docker build -t dev_image ./docker/dev --load

## Restart local dev container
dev/restart:
	@make dev/stop
	@make dev/start

## Initialize and setup the local dev environment
dev/setup:
	@make dev/build
	@make dev/start

## Shell into the running local dev container (see `dev/setup`)
dev/sh:
	docker exec -it dev_sak /bin/bash --login

## Start local dev container
dev/start:
	docker run -d --restart always --name dev_sak --env-file .env -v $(PWD):/app -w /app --entrypoint "" dev_image tail -f /dev/null

## Stop and remove the running local dev container
dev/stop:
	docker stop dev_sak && docker rm dev_sak
