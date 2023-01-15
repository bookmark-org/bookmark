defmodule Bookmark.BookmarkContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bookmark.BookmarkContext` context.
  """

  @doc """
  Generate a archive.
  """
  def archive_fixture(attrs \\ %{}) do
      attrs
      |> Enum.into(%{
        name: "some name"
      })
  end
end
