defmodule BookmarkWeb.ArchiveControllerTest do
  use BookmarkWeb.ConnCase

  import Bookmark.BookmarkContextFixtures

  @invalid_attrs %{name: nil}

  describe "create archive" do
    test "redirects when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.archive_path(conn, :create), @invalid_attrs)
      assert html_response(conn, 302)
    end
  end
end
