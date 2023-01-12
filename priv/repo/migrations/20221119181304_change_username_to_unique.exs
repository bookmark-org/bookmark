defmodule Bookmark.Repo.Migrations.ChangeUsernameToUnique do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :username, :text, null: false
    end

    create unique_index(:users, [:username])
  end
end
