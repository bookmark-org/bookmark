defmodule BookmarkWeb.WalletControllerTest do
  use BookmarkWeb.ConnCase

  import Bookmark.WalletsFixtures

  @create_attrs %{wallet_id: "some wallet_id"}
  @update_attrs %{wallet_id: "some updated wallet_id"}
  @invalid_attrs %{wallet_id: nil}

  describe "index" do
    test "lists all wallets", %{conn: conn} do
      conn = get(conn, Routes.wallet_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Wallets"
    end
  end

  describe "new wallet" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.wallet_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wallet"
    end
  end

  describe "create wallet" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.wallet_path(conn, :create), wallet: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.wallet_path(conn, :show, id)

      conn = get(conn, Routes.wallet_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Wallet"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.wallet_path(conn, :create), wallet: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wallet"
    end
  end

  describe "edit wallet" do
    setup [:create_wallet]

    test "renders form for editing chosen wallet", %{conn: conn, wallet: wallet} do
      conn = get(conn, Routes.wallet_path(conn, :edit, wallet))
      assert html_response(conn, 200) =~ "Edit Wallet"
    end
  end

  describe "update wallet" do
    setup [:create_wallet]

    test "redirects when data is valid", %{conn: conn, wallet: wallet} do
      conn = put(conn, Routes.wallet_path(conn, :update, wallet), wallet: @update_attrs)
      assert redirected_to(conn) == Routes.wallet_path(conn, :show, wallet)

      conn = get(conn, Routes.wallet_path(conn, :show, wallet))
      assert html_response(conn, 200) =~ "some updated wallet_id"
    end

    test "renders errors when data is invalid", %{conn: conn, wallet: wallet} do
      conn = put(conn, Routes.wallet_path(conn, :update, wallet), wallet: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Wallet"
    end
  end

  describe "delete wallet" do
    setup [:create_wallet]

    test "deletes chosen wallet", %{conn: conn, wallet: wallet} do
      conn = delete(conn, Routes.wallet_path(conn, :delete, wallet))
      assert redirected_to(conn) == Routes.wallet_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.wallet_path(conn, :show, wallet))
      end
    end
  end

  defp create_wallet(_) do
    wallet = wallet_fixture()
    %{wallet: wallet}
  end
end
