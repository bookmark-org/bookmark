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
* Edit `ArchiveBox.conf` with the following settings

```
[SERVER_CONFIG]
SECRET_KEY = <your secret key>
TIMEOUT = 120
SAVE_TITLE = TRUE
SAVE_WGET = TRUE
SAVE_WARC = FALSE
SAVE_FAVICON = FALSE
SAFE_PDF = TRUE
SAVE_SCREENSHOT = TRUE
SAVE_DOM = FALSE
SAVE_SINGLEFILE = FALSE
SAVE_READABILITY = FALSE
SAVE_GIT = FALSE
SAVE_MEDIA = FALSE
SUBMIT_ARCHIVE_DOT_ORG = FALSE
CHECK_SSL_VALIDITY = FALSE

[ARCHIVE_METHOD_TOGGLES]
SAVE_MERCURY = FALSE
```

* Make sure you have postgres running and `config/dev.exs` is setup to
talk to your db. 
* Install elixir dependencies with `mix deps.get`.
* Create and migrate your database with `mix ecto.setup`.
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.
* For anonymous archives to work, you must register a new user with `anonymous@bookmark.org`
as email.

Now you can visit [`localhost:4000`](http://localhost:4000) 
