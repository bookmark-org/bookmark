# Bookmark

This is the repo containing the [bookmark.org](https://bookmark.org/)
code.

## Running

Clone this repo `git clone https://github.com/bookmark-org/bookmark.git`

Make sure you have posgres running and `config/dev.exs` is setup to
talk to your db. 

[Install `archivebox`](https://archivebox.io/). By default `archivebox` installs using Docker, but
this is not suitable for bookmark as we need them running side by side.

In the `priv/static` folder create the archive `mkdir -p priv/static/archive`
`cd` into this dir and initialize it `archivebox init --setup`. After this
you should be all setup to run ecto and phoenix:

* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.setup`
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) 
