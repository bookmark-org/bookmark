defmodule BookmarkWeb.UserSessionController do
  use BookmarkWeb, :controller

  alias Bookmark.Accounts
  alias BookmarkWeb.UserAuth

  def new(conn, _params) do
    title = "bookmark.org login"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "login to bookmark.org to archive, share, and earn"}
    ]

    render(conn, "new.html",
      error_message: nil,
      title: title,
      meta_attrs: attrs_list
    )
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Accounts.get_user_by_email_and_password(email, password) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def create(conn, %{"username" => username, "wallet_key" => wallet_key} = user_params) do
    if user = Accounts.get_user_by_username_and_wallet_key(username, wallet_key) do
      UserAuth.log_in_user(conn, user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
