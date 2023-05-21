# Bookmark

This repository contains the code for [bookmark.org](https://bookmark.org/), an online service that allows users to archive and organize important web links.

## Setup

1. Install [Docker](https://docs.docker.com/engine/install/). Don't forget to perform the [Docker post-installation](https://docs.docker.com/engine/install/linux-postinstall/).

2. Optional: Create the following `.env` file in the root folder of this project (only required for archive summary generated with AI)

```
OPENAI_API_KEY=<api-key>
```

3. Optional: Login to the Docker registry (only required for Docker image pushes)

```
$ docker login -u bookmarkorg -p <registry-password>
```

## Basic Commands: Development

Run the app:

```
# Install Elixir dependencies
mix deps.get

# Run the Elixir app locally + DB and an Archivebox server in containers
make dev
```

Now you can visit [`localhost:4000`](http://localhost:4000) 

Stop the app:

```
make stop # Terminates the execution of all containers
```

Push image to deployment:

```
make push-images
```

## Basic Commands: Production

1. Download the latest tagged image from the Docker registry

```
make pull-images
```

2. Stop old containers

```
make stop
```

3. Run the Docker project

```
make prod
```


Now you can visit [`localhost:4000`](http://localhost:4000)

## Clean containers

After using the containers, you can destroy them along with their volumes (which contain the archives) using `make clean`.

## Available tasks

You can see available tasks (build, dev, prod, etc.) and what they do with `make`.