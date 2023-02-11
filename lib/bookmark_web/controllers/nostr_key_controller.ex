defmodule BookmarkWeb.NostrKeyController do
  use BookmarkWeb, :controller

  alias Bookmark.Nostr
  alias Bookmark.Nostr.Key

  action_fallback BookmarkWeb.FallbackController

  def index(conn, %{"name" => name}) do
    keys = Nostr.list_keys(name)
    render(conn, "index.json", keys: keys)
  end

  def index(conn, _params) do
    keys = Nostr.list_keys()
    render(conn, "index.json", keys: keys)
  end

  def create(conn, %{"key" => key_params}) do
    with {:ok, %Key{} = key} <- Nostr.create_key(key_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.nostr_key_path(conn, :show, key))
      |> render("show.json", key: key)
    end
  end

  def show(conn, %{"id" => id}) do
    key = Nostr.get_key!(id)
    render(conn, "show.json", key: key)
  end

  def update(conn, %{"id" => id, "key" => key_params}) do
    key = Nostr.get_key!(id)

    with {:ok, %Key{} = key} <- Nostr.update_key(key, key_params) do
      render(conn, "show.json", key: key)
    end
  end

  def delete(conn, %{"id" => id}) do
    key = Nostr.get_key!(id)

    with {:ok, %Key{}} <- Nostr.delete_key(key) do
      send_resp(conn, :no_content, "")
    end
  end
end
