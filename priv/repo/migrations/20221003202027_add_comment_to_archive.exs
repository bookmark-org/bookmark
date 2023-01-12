defmodule Bookmark.Repo.Migrations.AddCommentToArchive do
  use Ecto.Migration

  def change do
    alter table(:archives) do
      add :comment, :string
    end
  end
end
