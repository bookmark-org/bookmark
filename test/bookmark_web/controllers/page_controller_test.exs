defmodule BookmarkWeb.PageControllerTest do
  use BookmarkWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Bookmark.org - Archive links and earn rewards ⚡"
  end
end
