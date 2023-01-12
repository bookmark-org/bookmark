defmodule Bookmark.WalletsTest do
  use Bookmark.DataCase

  alias Bookmark.Wallets
  alias Bookmark.Wallets.Wallet

  import Bookmark.WalletsFixtures

  @invalid_attrs %{id: nil}

  describe "wallets" do
    test "create_wallet/1 with valid data creates a wallet" do
      valid_attrs = %{id: "some id", wallet_id: "some wallet_id"}

      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(valid_attrs)
      assert wallet.id == "some id"
      assert wallet.wallet_id == "some wallet_id"
    end

    test "update_wallet/2 with valid data updates the wallet" do
      wallet = wallet_fixture()
      update_attrs = %{id: "some updated id"}

      assert {:ok, %Wallet{} = wallet} = Wallets.update_wallet(wallet, update_attrs)
      assert wallet.id == "some updated id"
    end

    test "change_wallet/1 returns a wallet changeset" do
      wallet = wallet_fixture()
      assert %Ecto.Changeset{} = Wallets.change_wallet(wallet)
    end

    @invalid_attrs %{wallet_id: nil}

    test "list_wallets/0 returns all wallets" do
      wallet = wallet_fixture()
      assert Wallets.list_wallets() == [wallet]
    end

    test "get_wallet!/1 returns the wallet with given id" do
      wallet = wallet_fixture()
      assert Wallets.get_wallet!(wallet.id) == wallet
    end

    test "create_wallet/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wallets.create_wallet(@invalid_attrs)
    end

    test "update_wallet/2 with invalid data returns error changeset" do
      wallet = wallet_fixture()
      assert {:error, %Ecto.Changeset{}} = Wallets.update_wallet(wallet, @invalid_attrs)
      assert wallet == Wallets.get_wallet!(wallet.id)
    end

    test "delete_wallet/1 deletes the wallet" do
      wallet = wallet_fixture()
      assert {:ok, %Wallet{}} = Wallets.delete_wallet(wallet)
      assert_raise Ecto.NoResultsError, fn -> Wallets.get_wallet!(wallet.id) end
    end
  end
end
