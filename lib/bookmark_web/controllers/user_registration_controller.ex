defmodule BookmarkWeb.UserRegistrationController do
  use BookmarkWeb, :controller

  alias Bookmark.Accounts
  alias Bookmark.Accounts.User
  alias BookmarkWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    title = "bookmark.org user registration"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "join bookmark.org to archive, share, and earn"}
    ]

    render(conn, "new.html",
      changeset: changeset,
      title: title,
      meta_attrs: attrs_list
    )
  end

  def create(conn, %{"user" => user_params}) do
    wallet_key = BookmarkWeb.WalletController.get_new_wallet_key()
    new_params = Map.put(user_params, "wallet_key", wallet_key)

    case Accounts.register_user(new_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(
          :info,
          "Backup your wallet key " <> wallet_key <> " you will not see this message again"
        )
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, meta_attrs: nil, title: nil)
    end
  end
end
