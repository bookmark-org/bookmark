defmodule Bookmark.Repo do
  use Ecto.Repo,
    otp_app: :bookmark,
    adapter: Ecto.Adapters.Postgres
end
