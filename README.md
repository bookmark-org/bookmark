# Bookmark

This is the repo containing the [bookmark.org](https://bookmark.org/)
code.


## Running

Follow these steps to run bookmark locally:

* Clone this repo `git clone https://github.com/bookmark-org/bookmark.git`
* [Install `archivebox`](https://archivebox.io/). By default `archivebox` installs using Docker, but
this is not suitable for bookmark as we need them running side by side. One way to do this
is to take [this](https://raw.githubusercontent.com/ArchiveBox/ArchiveBox/dev/bin/setup.sh)
script and strip the `docker` and `docker-compose` parts.
* In the `priv/static` folder create the archive folder `mkdir -p priv/static/archive`,
`cd` into it and initialize the archive: `archivebox init --setup`.
* Make sure you have posgres running and `config/dev.exs` is setup to
talk to your db. 
* Install elixir dependencies with `mix deps.get`.
* Create and migrate your database with `mix ecto.setup`.
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) 
