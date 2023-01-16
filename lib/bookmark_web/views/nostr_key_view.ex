defmodule BookmarkWeb.NostrKeyView do
  use BookmarkWeb, :view
  alias BookmarkWeb.NostrKeyView

  def render("index.json", %{keys: keys}) do
    %{names: keys}
  end

  def render("show.json", %{key: key}) do
    %{data: render_one(key, NostrKeyView, "key.json")}
  end

  def render("key.json", %{key: key}) do
    %{
      id: key.id,
      pubkey: key.pubkey,
      name: key.name,
      relays: key.relays
    }
  end
end
