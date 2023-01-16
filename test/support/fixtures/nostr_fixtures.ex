defmodule Bookmark.NostrFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bookmark.Nostr` context.
  """

  @doc """
  Generate a key.
  """
  def key_fixture(attrs \\ %{}) do
    {:ok, key} =
      attrs
      |> Enum.into(%{
        name: "some name",
        pubkey: "some pubkey",
        relays: []
      })
      |> Bookmark.Nostr.create_key()

    key
  end
end
