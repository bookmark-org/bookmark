include .env
export

default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: build
build: # Build docker image.
	docker build -t bookmark:latest .

.PHONY: prod
prod: # Run bookmark dockerized in prod mode. Dockerized Database and ArchiveboxServer
	docker compose up

.PHONY: dev
dev: # Run bookmark locally in dev mode. Dockerized Database and ArchiveboxServer
	docker compose -f docker-compose-dev.yml up -d
	BOOKMARK_ARCHIVEBOX_URL=http://localhost:5000/add  iex -S mix phx.server
	docker compose stop

.PHONY: stop
stop: # Terminates the execution of all containers
	docker compose down --remove-orphans

.PHONY: clean
clean: # Terminates the execution of all containers + delete volumes
	docker compose down -v --remove-orphans
	rm -r priv/static/archive/*

.PHONY: push-image
push-image: # Push image to registry
	docker tag bookmark:latest $(DOCKER_REGISTRY)/bookmark:latest
	docker push $(DOCKER_REGISTRY)/bookmark:latest

.PHONY: pull-images
pull-images: # Pull images from registry
	docker pull $(DOCKER_REGISTRY)/bookmark:latest
	docker pull $(DOCKER_REGISTRY)/archivebox-server:latest