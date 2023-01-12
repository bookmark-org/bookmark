defmodule Bookmark.Repo.Migrations.AddUserIdToArchives do
  use Ecto.Migration

  def change do
    alter table(:archives) do
      add :user_id, references(:users, on_delete: :nothing)
    end
  end
end
