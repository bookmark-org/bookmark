defmodule Bookmark.Repo.Migrations.AddNostrKeyToUser do
  use Ecto.Migration

  def change do
    alter table(:nostr_keys) do
      remove(:id)
      modify(:pubkey, :string, primary_key: true)
      add :user_id, references(:users)
    end

    alter table(:users) do
      add :nostr_key, references(:nostr_keys, type: :string, column: :pubkey, primary_key: true)
    end
  end
end
