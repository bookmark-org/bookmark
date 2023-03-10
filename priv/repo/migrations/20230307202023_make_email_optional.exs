defmodule Bookmark.Repo.Migrations.MakeEmailOptional do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :email, :citext, null: true
    end
  end
end
