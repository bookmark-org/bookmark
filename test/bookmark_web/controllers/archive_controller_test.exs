defmodule BookmarkWeb.ArchiveControllerTest do
  use BookmarkWeb.ConnCase

  import Bookmark.BookmarkContextFixtures

  @create_attrs %{name: "some name"}
  @invalid_attrs %{name: nil}

  describe "create archive" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.archive_path(conn, :create), archive: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.archive_path(conn, :show, id)

      conn = get(conn, Routes.archive_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Archive"
    end

    test "redirects when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.archive_path(conn, :create), archive: @invalid_attrs)
      assert html_response(conn, 302)
    end
  end

  defp create_archive(_) do
    archive = archive_fixture()
    %{archive: archive}
  end
end
