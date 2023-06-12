# Script for backifill fields of archives. You can run it as:
#
#     mix run priv/repo/backfill.exs

alias Bookmark.Repo
alias Bookmark.Archives.Archive
alias Bookmark.Archives

# Backfill
Repo.all(Archive) |> Enum.each(fn a ->
  if a.summary == nil || a.summary == "Summary not available" do
    Archives.add_summary(a)
  end

  if a.title == nil do
    Archive.changeset(a, %{title: Archives.get_title(a.name)})
    |> Repo.update()
  end
end)
