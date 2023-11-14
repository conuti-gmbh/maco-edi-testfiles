include .env
WEBSERVER_CONTAINER := webserver
DOCKER_COMPOSE := docker-compose
MAKE := make
HOST := http://localhost

################################################################
## Composer
################################################################
info: ## Starts the application for local development
	@echo "Welcome"

start: ## Starts the application for local development
	@ID_RSA="$(shell cat ~/.ssh/id_rsa | sed '$$ ! s/$$/\\n/' | tr -d '\n')" docker-compose up webserver --remove-orphans -d
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) composer install
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) composer dumpautoload
	@$(MAKE) -s info

stop: ## Stop the entire docker compose stack
	$(DOCKER_COMPOSE) stop

install: ## Run composer install
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) composer install

update: ## Run composer update
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) composer update

dumpautoload: ## Run composer dumpautoload
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) composer dumpautoload

update-lock: ## Updates composer.lock
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) composer update --lock

shell: ## Run a shell inside the webserver container
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) bash

clean-dist: ## Stops and removes all containers from the docker compose stack, as well as their images
	$(DOCKER_COMPOSE) down --rmi all -v


################################################################
# PHP Coding Standards Checker
################################################################

php-cs-check: #Run code style check for the src folder
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) vendor/bin/phpcs -s -p --colors

php-cbf: #Run code style cbf
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) vendor/bin/phpcbf -s -p --colors

php-md-check: #Run php md
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) php vendor/bin/phpmd ./src html phpmd.xml --reportfile tests/_output/phpmd_html/index.html --suffixes php

php-stan-check: #Run php-stan
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) vendor/bin/phpstan analyse -c phpstan.neon --memory-limit 256M

php-stan-generate-baseline: #Run php-stan-generate-baseline
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) vendor/bin/phpstan analyse -c phpstan.neon --memory-limit 256M --generate-baseline

################################################################
## PHP Unit
################################################################

php-unit: ## Run codeception build by config changes
	$(DOCKER_COMPOSE) exec $(WEBSERVER_CONTAINER) vendor/bin/phpunit --verbose
