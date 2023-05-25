defmodule Bookmark.ArchivesTest do
  use Bookmark.DataCase
  use ExUnit.Case, async: true
  use Mimic

  alias Bookmark.Archives
  alias Bookmark.Archives.Archive

  import Bookmark.BookmarkContextFixtures

  describe "archives" do
    @invalid_attrs %{name: nil}

    test "list_archives/0 returns all archives" do
      archive = archive_fixture()
      [archive_from_list] = Archives.list_archives()
      assert archive_from_list |> Bookmark.Repo.preload(:user) == archive
    end

    test "create_archive/1 with valid data creates a archive" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Archive{} = archive} = Archives.create_archive(valid_attrs, nil)
      assert archive.name == "some name"
    end

    test "create_archive/1 with invalid data returns error changeset" do
      assert_raise(MatchError,  fn -> Archives.create_archive(@invalid_attrs, nil) end)
    end

    test "get_archives_by_user/1 returns all archives from the user" do
      # Create 2 users
      assert {:ok, user1} =  Bookmark.Accounts.register_user(%{
        email: "user1@foo.com",
        username: "user1",
        password: "some_password"
      })

      assert {:ok, user2} =  Bookmark.Accounts.register_user(%{
        email: "user2@foo.com",
        username: "user2",
        password: "some_password"
      })

      # Add 2 archives to user1
      assert {:ok, %Archive{} = archive1} = Archives.create_archive(%{name: "some name"}, user1)
      assert {:ok, %Archive{} = archive2} = Archives.create_archive(%{name: "some name"}, user1)
      # Add 1 archive to user2
      assert {:ok, %Archive{} = archive3} = Archives.create_archive(%{name: "some name"}, user2)

      # Test get_archives_by_user
      assert [archive_1, archive2] = Bookmark.Archives.get_archives_by_user(user1)
      assert [archive3] = Bookmark.Archives.get_archives_by_user(user2)
    end

    test "archive_url/2 with valid data creates archives" do
      # Mocked functions
      Mimic.expect(Archives, :archivebox, fn _url -> {:ok, "archive/some_id"} end)
      Mimic.expect(Archives, :get_title, fn _archive ->  "some_title" end )

      # Test archive creation
      assert {:ok, %Archive{} = archive} = Archives.archive_url("some_url", nil)
      assert archive.name == "some_id"
      assert archive.title == "some_title"
    end

    test "bulk_archives/3 with valid data creates archives" do
      # Mocked functions
      Mimic.expect(Archives, :archivebox, 2, fn url -> {:ok, "archive/#{url}"} end)
      Mimic.expect(Archives, :get_title, 2, fn _archive ->  "some_title" end )

      # Test archives creation
      url_list = ["foo.com", "bar.com"]
      assert [{:ok, %Archive{} = a1}, {:ok, %Archive{} = a2}] = Archives.bulk_archives(url_list, nil)
      assert a1.name == "foo.com"
      assert a2.name == "bar.com"
    end

    test "bulk_archives/3 doesn't crash if there is an invalid archive" do
      # Mocked functions
      Mimic.expect(Archives, :archive_url, fn _url, _user -> {:ok, %Archive{name: "foo.com"}} end)
      Mimic.expect(Archives, :archive_url, fn _url, _user -> raise "Fatal error" end)

      # Test archives creation
      url_list = ["foo.com", "bar.com"]
      assert [{:ok, %Archive{} = a1}, {:error, _}] = Archives.bulk_archives(url_list, nil)
      assert a1.name == "foo.com"
    end
  end
end
