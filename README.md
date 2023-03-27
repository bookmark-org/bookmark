# Bookmark

This is the repo containing the [bookmark.org](https://bookmark.org/)
code.

## Running

Follow these steps to run bookmark locally:

* Clone this repo `git clone https://github.com/bookmark-org/bookmark.git`
* Install [docker](https://docs.docker.com/engine/install/)
* Install elixir dependencies with `mix deps.get`.
* Run app with `make dev`

Now you can visit [`localhost:4000`](http://localhost:4000) 

## Running in production mode

* Build image with `make build`
* Run containers with `make prod`