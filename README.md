# Bookmark

This is the repo containing the [bookmark.org](https://bookmark.org/) code.

## Prerequisites
* Install [docker](https://docs.docker.com/engine/install/)
* Download [ArchiveboxServer repository](https://github.com/bookmark-org/archivebox) and build the image with `make build`
* Clone this repository `git clone https://github.com/bookmark-org/bookmark.git`
* Create the archive folder with `mkdir priv/static/archive/` inside this repository.

## Running

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