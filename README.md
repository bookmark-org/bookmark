# Bookmark

This is the repo containing the [bookmark.org](https://bookmark.org/) code.

## Setup

1. Install [docker](https://docs.docker.com/engine/install/)
2. Create the archive folder with `mkdir priv/static/archive/` inside this repository.
3. In the root of the project `/bookmark`, create a `.env` file with the following content:

```
DOCKER_REGISTRY=<registry-name>
```

4. Optional: Login to the Docker registry (required for Docker image pushes)

```
$ docker login -u <registry-name> -p <registry-password>
```

## Running in development mode

Follow these steps to run bookmark locally:

* Install elixir dependencies with `mix deps.get`.
* Run app with `make dev`

Now you can visit [`localhost:4000`](http://localhost:4000) 

## Running in production mode

* Build image with `make build`
* Run containers with `make prod`

Now you can visit [`localhost:4000`](http://localhost:4000)

## Destroy containers

* After using the containers, you can destroy them using `make down`

## Available tasks

You can see available tasks (build, dev, prod, etc) and what they do with `make`