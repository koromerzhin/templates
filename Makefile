.DEFAULT_GOAL := help
%:
	@:

help:
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

package-lock.json: package.json
	npm install

node_modules: package-lock.json
	npm install

install: node_modules ## Installation application
	@make git-submodule -i
	git submodule foreach make install

contributors: ## Contributors
	@npm run contributors

contributors-add: ## add Contributors
	@npm run contributors add

contributors-check: ## check Contributors
	@npm run contributors check

contributors-generate: ## generate Contributors
	@npm run contributors generate

docker-image-pull: ## Get docker image
	git submodule foreach make docker-image-pull

docker-deploy: ## deploy
	git submodule foreach make docker-deploy

docker-stop: ## docker stop
	git submodule foreach make docker-stop

git-commit: ## Commit data
	npm run commit

git-check: ## CHECK before
	@make contributors-check -i
	@git status

git-submodule: ## Git submodules
	@git submodule update --init --recursive --remote

git-update: ## Git submodule update
	git pull origin develop
	git submodule foreach git pull origin develop

linter-readme: ## linter README.md
	@npm run linter-markdown README.md
