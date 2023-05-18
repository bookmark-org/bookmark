defmodule Bookmark.Repo.Migrations.AddTitleAndSummaryToArchive do
  use Ecto.Migration

  def change do
    alter table(:archives) do
      add :summary, :text
      add :title, :string
    end
  end
end
