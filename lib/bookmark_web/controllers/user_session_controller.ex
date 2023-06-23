defmodule BookmarkWeb.UserSessionController do
  use BookmarkWeb, :controller

  # Prevents receiving external login attempts
  plug :protect_from_forgery

  alias Bookmark.Accounts
  alias BookmarkWeb.UserAuth


  #*********************************** Actions *************************************
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

  def create(conn, %{"user" => user_params}) do
    login_type = user_params["login_type"]

    if user = get_user(user_params, login_type) do
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

  #*********************************** Helper functions *************************************
  def get_user(params, login_type) do
    case login_type do
      "email" ->
        %{"email" => email, "password" => password} = params
        Accounts.get_user_by_email_and_password(email, password)
      "nostr" ->
        %{"nostr_key" => nostr_key} = params
        Accounts.get_user_by_nostr_key(nostr_key)
    end
  end
end
