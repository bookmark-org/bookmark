defmodule Bookmark.Repo.Migrations.CreateKeys do
  use Ecto.Migration

  def change do
    create table(:nostr_keys) do
      add :pubkey, :string
      add :name, :string
      add :relays, {:array, :string}

      timestamps()
    end
  end
end
