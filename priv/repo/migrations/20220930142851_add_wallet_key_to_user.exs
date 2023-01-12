defmodule Bookmark.Repo.Migrations.AddWalletKeyToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :wallet_key, :string
    end
  end
end
