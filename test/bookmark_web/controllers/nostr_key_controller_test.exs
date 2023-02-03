defmodule BookmarkWeb.NostrKeyControllerTest do
  use BookmarkWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all keys using name", %{conn: conn} do
      conn = get(conn, Routes.nostr_key_path(conn, :index, %{"name" => "bob"}))
      assert json_response(conn, 200) == %{"names" => []}
    end

    test "lists all keys", %{conn: conn} do
      conn = get(conn, Routes.nostr_key_path(conn, :index))
      assert json_response(conn, 200) == %{"names" => []}
    end
  end
end
