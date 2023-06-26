defmodule Bookmark.NostrTest do
  use Bookmark.DataCase

  alias Bookmark.Nostr

  describe "keys" do
    alias Bookmark.Nostr.Key

    import Bookmark.NostrFixtures

    @invalid_attrs %{name: nil, pubkey: nil, relays: nil}

    test "list_keys/0 returns all keys" do
      key = key_fixture()
      assert Nostr.list_keys() == [key]
    end

    test "get_key!/1 returns the key with given id" do
      key = key_fixture()
      assert Nostr.get_key!(key.pubkey) == key
    end

    test "create_key/1 with valid data creates a key" do
      valid_attrs = %{name: "some name", pubkey: "some pubkey", relays: []}

      assert {:ok, %Key{} = key} = Nostr.create_key(valid_attrs)
      assert key.name == "some name"
      assert key.pubkey == "some pubkey"
      assert key.relays == []
    end

    test "create_key/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Nostr.create_key(@invalid_attrs)
    end

    test "update_key/2 with valid data updates the key" do
      key = key_fixture()
      update_attrs = %{name: "some updated name", pubkey: "some updated pubkey", relays: []}

      assert {:ok, %Key{} = key} = Nostr.update_key(key, update_attrs)
      assert key.name == "some updated name"
      assert key.pubkey == "some updated pubkey"
      assert key.relays == []
    end

    test "update_key/2 with invalid data returns error changeset" do
      key = key_fixture()
      assert {:error, %Ecto.Changeset{}} = Nostr.update_key(key, @invalid_attrs)
      assert key == Nostr.get_key!(key.pubkey)
    end

    test "delete_key/1 deletes the key" do
      key = key_fixture()
      assert {:ok, %Key{}} = Nostr.delete_key(key)
      assert_raise Ecto.NoResultsError, fn -> Nostr.get_key!(key.pubkey) end
    end

    test "change_key/1 returns a key changeset" do
      key = key_fixture()
      assert %Ecto.Changeset{} = Nostr.change_key(key)
    end
  end
end
