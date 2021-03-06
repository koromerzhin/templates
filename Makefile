.DEFAULT_GOAL := help

SUPPORTED_COMMANDS := contributors docker git linter
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

node_modules:
	@npm install

install: node_modules ## Installation application
	@make git submodule -i
	@git submodule foreach make install

contributors: node_modules ## Contributors
ifeq ($(COMMAND_ARGS),add)
	@npm run contributors add
else ifeq ($(COMMAND_ARGS),check)
	@npm run contributors check
else ifeq ($(COMMAND_ARGS),generate)
	@npm run contributors generate
else
	@npm run contributors
endif

docker: ## Scripts docker
ifeq ($(COMMAND_ARGS),deploy)
	@git submodule foreach make docker deploy
else ifeq ($(COMMAND_ARGS),stop)
	@git submodule foreach make docker stop
else ifeq ($(COMMAND_ARGS),ls)
	@git submodule foreach make docker ls
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make docker ARGUMENT"
	@echo "---"
	@echo "deploy: deploy"
	@echo "ls: docker service"
	@echo "stop: docker stop"
endif

git: ## Scripts GIT
ifeq ($(COMMAND_ARGS),status-all)
	@git submodule foreach git status
else ifeq ($(COMMAND_ARGS),status)
	@git status
else ifeq ($(COMMAND_ARGS),submodule)
	@git submodule update --init --recursive --remote
else ifeq ($(COMMAND_ARGS),update)
	@git pull origin develop
	@make git submodule -i
	@git submodule foreach git checkout develop
	@git submodule foreach git pull origin develop
else ifeq ($(COMMAND_ARGS),check)
	@make contributors check -i
	@make linter all -i
	@make git status -i
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make git ARGUMENT"
	@echo "---"
	@echo "check: CHECK before"
	@echo "update: submodule update"
	@echo "submodule: Git submodules"
	@echo "status: status"
	@echo "status-all: status ALL"
endif

linter: ## Scripts Linter
ifeq ($(COMMAND_ARGS),all)
	@make linter readme -i
else ifeq ($(COMMAND_ARGS),readme)
	@npm run linter-markdown README.md
else
	@echo "ARGUMENT missing"
	@echo "---"
	@echo "make linter ARGUMENT"
	@echo "---"
	@echo "all: ## Launch all linter"
	@echo "readme: linter README.md"
endif