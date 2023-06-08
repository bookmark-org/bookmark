defmodule BookmarkWeb.NostrController do
  use BookmarkWeb, :controller
  require Logger

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # Given a Nostr user Public Key, obtains all the links of the user's notes, and redirect
  # to the bulk archive page precharging all the links
  def create(conn, params) do
    nostr_key = params["nostr_key"]

    conn
    |> put_flash(:info, "Redirecting to bulk archive page...")
    |> put_session(:nostr_key, nostr_key)
    |> redirect(to: Routes.live_path(conn, BookmarkWeb.BulkArchivesLive))
  end
end
