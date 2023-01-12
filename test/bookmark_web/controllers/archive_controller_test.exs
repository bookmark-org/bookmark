defmodule BookmarkWeb.ArchiveControllerTest do
  use BookmarkWeb.ConnCase

  import Bookmark.BookmarkContextFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all archives", %{conn: conn} do
      conn = get(conn, Routes.archive_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Archives"
    end
  end

  describe "new archive" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.archive_path(conn, :new))
      assert html_response(conn, 200) =~ "New Archive"
    end
  end

  describe "create archive" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.archive_path(conn, :create), archive: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.archive_path(conn, :show, id)

      conn = get(conn, Routes.archive_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Archive"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.archive_path(conn, :create), archive: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Archive"
    end
  end

  describe "edit archive" do
    setup [:create_archive]

    test "renders form for editing chosen archive", %{conn: conn, archive: archive} do
      conn = get(conn, Routes.archive_path(conn, :edit, archive))
      assert html_response(conn, 200) =~ "Edit Archive"
    end
  end

  describe "update archive" do
    setup [:create_archive]

    test "redirects when data is valid", %{conn: conn, archive: archive} do
      conn = put(conn, Routes.archive_path(conn, :update, archive), archive: @update_attrs)
      assert redirected_to(conn) == Routes.archive_path(conn, :show, archive)

      conn = get(conn, Routes.archive_path(conn, :show, archive))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, archive: archive} do
      conn = put(conn, Routes.archive_path(conn, :update, archive), archive: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Archive"
    end
  end

  defp create_archive(_) do
    archive = archive_fixture()
    %{archive: archive}
  end
end
