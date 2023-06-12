defmodule BookmarkWeb.WalletControllerTest do
  use BookmarkWeb.ConnCase

  describe "index" do
    test "lists all wallets", %{conn: conn} do
      conn = get(conn, Routes.wallet_path(conn, :index))
      assert html_response(conn, 200) =~ "Deposit"
    end
  end
end
