SHELL_SCRIPTS := bin/lab lib/common.sh tests/e2e.sh $(wildcard labs/*/*.sh labs/*/solution/*.sh labs/*/files/*/*.sh labs/*/solution/*/*.sh)

.PHONY: help lint test

help:
	@echo "make lint   シェルスクリプトを shellcheck で検査"
	@echo "make test   全ラボの E2E テスト (Docker が必要)"

lint:
	shellcheck -x $(SHELL_SCRIPTS)

test:
	tests/e2e.sh
