defmodule Bookmark.WalletsTest do
  use Bookmark.DataCase

  alias Bookmark.Wallets
  alias Bookmark.Wallets.Wallet

  import Bookmark.WalletsFixtures

  @invalid_attrs %{id: nil}

  describe "wallets" do
    test "create_wallet/1 with valid data creates a wallet" do
      valid_attrs = %{wallet_id: "some wallet_id"}

      assert {:ok, %Wallet{} = wallet} = Wallets.create_wallet(valid_attrs)
      assert wallet.id
      assert wallet.wallet_id == "some wallet_id"
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
  end
end
