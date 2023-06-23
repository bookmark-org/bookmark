defmodule BookmarkWeb.UserRegistrationController do
  use BookmarkWeb, :controller

  alias Bookmark.Accounts
  alias Bookmark.Accounts.User
  alias BookmarkWeb.UserAuth

  #*********************************** Actions *************************************
  def new(conn, params) do
    path = case params["type"] do
      "email" -> "new_with_email.html"
      "nostr" -> "new_with_nostr.html"
      _ ->"new.html"
    end

    render_new(conn, path)
  end

  def create(conn, %{"user" => user_params}) do
    register_type = user_params["register_type"]

    case create_user(user_params, register_type) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(
          :info,
          "Backup your wallet key " <> user.wallet_key <> " you will not see this message again"
        )
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "Error")

        render(conn, "new_with_#{register_type}.html", nostr_key: user_params["nostr_key"], changeset: changeset, meta_attrs: nil, title: nil)
    end
  end

  #*********************************** Helper functions *************************************
  defp render_new(conn, template_path) do
    changeset = Accounts.change_user_registration(%User{})
    title = "bookmark.org user registration"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "join bookmark.org to archive, share, and earn"}
    ]

    render(conn, template_path,
      nostr_key: nil,
      changeset: changeset,
      title: title,
      meta_attrs: attrs_list
    )
  end

  defp create_user(params, register_type) do
    wallet_key = BookmarkWeb.WalletController.get_new_wallet_key()

    case register_type do
      "email" ->
        IO.puts("Entro al create user: email")
        new_params = %{
          username: params["username"],
          password: params["password"],
          email: params["email"],
          wallet_key: wallet_key
        }
        Accounts.register_user(new_params)

      "nostr" ->
        nostr_key = %{pubkey: params["nostr_key"], relays: [], name: "_"}

        new_params = %{
          username: params["username"],
          email: nostr_key[:pubkey],
          nostr_key: nostr_key,
          wallet_key: wallet_key
        }
        Accounts.nostr_register_user(new_params)
    end
  end
end
