defmodule Bookmark.ArchivesTest do
  use Bookmark.DataCase

  alias Bookmark.Archives
  alias Bookmark.Archives.Archive
  alias Bookmark.Archives

  import Bookmark.BookmarkContextFixtures

  describe "archives" do
    @invalid_attrs %{name: nil}

    test "list_archives/0 returns all archives" do
      archive = archive_fixture()
      [archive_from_list] = Archives.list_archives()
      assert Map.replace(archive_from_list, :user, nil) == archive
    end

    test "create_archive/1 with valid data creates a archive" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Archive{} = archive} = Archives.create_archive(valid_attrs)
      assert archive.name == "some name"
    end

    test "create_archive/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Archives.create_archive(@invalid_attrs)
    end
  end
end
