SHELL:=/usr/bin/env bash

SMTP_PASS_SECRETID:="op://Infra/abcd1234/password"

default: help
.PHONY: help
help: # via https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: verify-op-signin
verify-op-signin:
	@op read ${SMTP_PASS_SECRETID} >/dev/null

.PHONY: pull
pull: ## Pull the latest images for this stack
	docker compose pull

.PHONY: up
up: verify-op-signin ## Run the ytdlbot stack as a daemon
	RUNNER_SMTP_PASS=$$(op read ${SMTP_PASS_SECRETID}) \
	  docker compose up -d
	  sudo tailscale serve --bg --https=8124 http://127.0.0.1:9124

.PHONY: down
down: ## Stop the ytdlbot stack
	docker compose down
	sudo tailscale serve --bg --https=8124 off
