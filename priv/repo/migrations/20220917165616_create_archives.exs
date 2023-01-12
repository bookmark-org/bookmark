defmodule Bookmark.Repo.Migrations.CreateArchives do
  use Ecto.Migration

  def change do
    create table(:archives) do
      add :name, :string

      timestamps()
    end
  end
end
