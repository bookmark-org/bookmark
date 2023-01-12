defmodule Bookmark.BookmarkContextFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bookmark.BookmarkContext` context.
  """

  @doc """
  Generate a archive.
  """
  def archive_fixture(attrs \\ %{}) do
    {:ok, archive} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Bookmark.BookmarkContext.create_archive()

    archive
  end
end
