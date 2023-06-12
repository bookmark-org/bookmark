Mimic.copy(Bookmark.Archives)
Mimic.copy(Req)
Mimic.copy(Bookmark.Wallets)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Bookmark.Repo, :manual)
