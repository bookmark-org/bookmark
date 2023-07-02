# Load environment variables from .env file
include .env
export

default: help

.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: build
build: # Build docker image.
	docker build -t bookmark:latest .
	docker tag bookmark:latest bookmarkorg/bookmark:latest

.PHONY: prod
prod: # Run bookmark dockerized in prod mode. Dockerized Database and ArchiveboxServer
	docker compose up

.PHONY: dev
dev: # Run bookmark locally in dev mode. Dockerized Database and ArchiveboxServer
	OPENAI_API_KEY=$(OPENAI_API_KEY)
	export OPENAI_API_KEY
	BOOKMARK_ARCHIVE_DELAY=$(BOOKMARK_ARCHIVE_DELAY)
	export BOOKMARK_ARCHIVE_DELAY
	docker compose -f docker-compose-dev.yml up -d
	BOOKMARK_ARCHIVEBOX_URL=http://localhost:5001/add \
	  BOOKMARK_NOSTR_CLIENT_URL=http://localhost:5005/links \
	  iex -S mix phx.server
	docker compose stop

.PHONY: console-prod
console-prod: # Executes interactive console in production mode
	docker exec -it bookmark-app /app/bin/bookmark remote

.PHONY: stop
stop: # Terminates the execution of all containers
	docker compose down --remove-orphans

.PHONY: clean
clean: # Terminates the execution of all containers + delete volumes
	@if [ "${IS_PROD}" = "true" ]; then \
		echo "You can't run 'make clean' in production.\nIf you want to stop the containers, run 'make stop'"; \
	else \
		echo "ATTENTION: You are on the verge of DELETING the ENTIRE database and files. Please be aware, this action is IRREVERSIBLE.\nAre you absolutely certain you want to proceed? Y/n"; \
		read response; \
		response=$$(echo "$$response" | tr '[:upper:]' '[:lower:]'); \
		if [ "$$response" = "y" ]; then \
			docker compose down -v --remove-orphans; \
			docker volume rm bookmark_db -f; \
			rm -r priv/static/archive/*; \
			echo "Successful deletion"; \
		else \
			echo "Operation aborted"; \
		fi \
	fi


.PHONY: push-image
push-image: # Push image to registry
	docker tag bookmark:latest bookmarkorg/bookmark:latest
	docker push bookmarkorg/bookmark:latest

.PHONY: pull-images
pull-images: # Pull images from registry
	docker pull bookmarkorg/bookmark:latest
	docker pull bookmarkorg/archivebox-server:latest
