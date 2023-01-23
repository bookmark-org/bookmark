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
      |> Bookmark.Archives.create_archive(
        Bookmark.Accounts.get_user_by_email("anonymous@bookmark.org")
      )

    archive
  end
end
