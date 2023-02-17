defmodule BookmarkWeb.Plug.Balance do
  alias Bookmark.Wallets

  import Plug.Conn

  def fetch_user_balance(conn, _opts) do
    user = conn.assigns.current_user

    assign(conn, :balance, Wallets.balance(user) || 0)
  end
end
