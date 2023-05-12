# Bookmark

This is the repo containing the [bookmark.org](https://bookmark.org/) code.

## Setup

1. Install [docker](https://docs.docker.com/engine/install/)
2. Create the archive folder with `mkdir priv/static/archive/` inside this repository.
3. Optional: Login to the Docker registry (required for Docker image pushes)

```
$ docker login -u bookmarkorg -p <registry-password>
```

## Basic Commands: Development

Run app:

```
# Install elixir dependencies
mix deps.get

# Run the Elixir app locally + DB and a Archivebox server in containers
make dev
```

Now you can visit [`localhost:4000`](http://localhost:4000) 


Stop app:

```
make stop # Terminates the execution of all containers
```

Push image to deployment:

```
make push-images
```

## Basic Commands: Production

1. Download latest tagged image from Docker registry

```
make pull-images
```

2. Stop old containers

```
make stop
```

3. Run docker project

```
make prod
```


Now you can visit [`localhost:4000`](http://localhost:4000)

## Clean containers

* After using the containers, you can destroy them with their volumes using `make clean`

## Available tasks

You can see available tasks (build, dev, prod, etc) and what they do with `make`