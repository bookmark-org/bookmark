defmodule Bookmark.Repo.Migrations.CreateWallets do
  use Ecto.Migration

  def change do
    create table(:wallets) do
      add :wallet_id, :string

      timestamps()
    end
  end
end
