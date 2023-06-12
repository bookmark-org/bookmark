defmodule BookmarkWeb.ArchiveController do
  use BookmarkWeb, :controller

  require Logger

  alias Ecto.Changeset

  @spec show(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    balance = Bookmark.Wallets.balance(user)

    list = Bookmark.Archives.index_data(id)
    canonical = list["canonical"]
    archive = Bookmark.Repo.get_by(Bookmark.Archives.Archive, name: id)

    archive_poster =
      if Map.get(archive, :user_id) do
        Bookmark.Repo.get_by(Bookmark.Accounts.User, id: archive.user_id)
      end

    image_url = Bookmark.Archives.directory() <> "/" <> id <> "/screenshot.png"

    attrs_list = [
      %{property: "og:title", content: list["title"]},
      %{property: "og:image", content: image_url},
      %{property: "og:description", content: "bookmark.org via " <> list["domain"]}
    ]

    render(
      conn,
      "index.html",
      id: id,
      balance: balance,
      url: list["base_url"],
      date: list["bookmarked_date"],
      domain: list["domain"],
      title: list["title"],
      wget_url: canonical["wget_path"],
      comment: Map.get(archive, :comment),
      archive_poster: archive_poster.username,
      meta_attrs: attrs_list
    )

    # more things we can add from our current data or textual analysis / analytics output
    # Number of Words / Tokens, Sentences, Paragraphs
  end

  @spec create(Plug.Conn.t(), any) :: Plug.Conn.t()
  def create(conn, param) do
    param
    |> validate_received_url()
    |> do_create(conn)
  end

  defp do_create(
         %{changes: changes, valid?: false, errors: [{_field, {error_message, _}}]},
         conn
       ) do
    url = changes[:url]

    conn
    |> put_flash(
      :error,
      if url do
        "#{url}: #{error_message}"
      else
        error_message
      end
    )
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp do_create(%{changes: %{url: url}}, conn) do
    user = conn.assigns.current_user

    with {:ok, archive} <- Bookmark.Archives.archive_url(url, user) do
      conn
      |> redirect(to: Routes.archive_path(conn, :show, archive.name))
    else
      {:error, :page_not_found} ->
        conn
        |> put_flash(:error, "Error: " <> url <> "  (not found)")
        |> redirect(to: "/")

      {:error, :cant_be_reached} ->
        conn
        |> put_flash(:error, "Error: " <> url <> "  (site can’t be reached)")
        |> redirect(to: "/")

      {:error, :already_exists} ->
        conn
        |> put_flash(:error, "Error: " <> url <> " (already exists)")
        |> redirect(to: "/")

      {:error, :failed_to_parse} ->
        conn
        |> put_flash(:error, "Error: " <> url <> " (invalid url format)")
        |> redirect(to: "/")

      {:error, :domain_not_allowed} ->
        conn
        |> put_flash(:error, "Error: " <> url <> " (domain not allowed)")
        |> redirect(to: "/")

      {:error, :timeout_error} ->
        conn
        |> put_flash(:error, "Error: Timeout Error")
        |> redirect(to: "/")

      _ ->
      conn
      |> put_flash(:error, "Error: Unexpected Server Error")
      |> redirect(to: "/")
    end
  end

  defp validate_received_url(params) do
    {%{}, %{url: :string}}
    |> Changeset.cast(params, [:url])
    |> Changeset.validate_required([:url])
  end
end
