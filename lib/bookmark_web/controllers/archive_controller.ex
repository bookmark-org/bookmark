defmodule BookmarkWeb.ArchiveController do
  use BookmarkWeb, :controller

  require Logger
  
  alias Ecto.Changeset

  def archivebox(url) do
    command = "cd #{directory()}; archivebox add #{url}"

    # FIXME: raise if cmd returns an error code
    System.cmd("sh", ["-c", command], cd: directory())
  end

  defp directory, do: System.fetch_env!("HOME") <> "/bookmark/priv/static/archive/"

  def index_data(archive_id) do
    file_path = directory() <> "archive/" <> archive_id
    File.read!(file_path <> "/index.json")
  end

  @spec view(Plug.Conn.t(), map) :: Plug.Conn.t()
  def view(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    balance = Bookmark.Wallets.wallet_balance(user.wallet_key)

    balance = balance.body["balance"]

    display_balance =
      if is_integer(balance) do
        balance / 1000
      end

    index_json = index_data(id)
    list = JSON.decode!(index_json)
    canonical = list["canonical"]
    archive = Bookmark.Repo.get_by(Bookmark.Archives.Archive, name: id)

    archive_poster =
      if archive[:user_id] do
        Bookmark.Repo.get_by(Bookmark.Accounts.User, id: archive.user_id)
      end

    image_url = directory() <> id <> "/screenshot.png"

    attrs_list = [
      %{property: "og:title", content: list["title"]},
      %{property: "og:image", content: image_url},
      %{property: "og:description", content: "bookmark.org via " <> list["domain"]}
    ]

    render(
      conn,
      "index.html",
      id: id,
      balance: display_balance,
      url: list["base_url"],
      date: list["bookmarked_date"],
      domain: list["domain"],
      title: list["title"],
      wget_url: canonical["wget_path"],
      comment: archive[:comment],
      archive_poster: archive_poster[:username],
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
         %{changes: %{url: url}, valid?: false, errors: [{_field, {error_message, _}}]},
         conn
       ) do
    conn
    |> put_flash(:error, "#{url}: #{error_message}")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  defp do_create(%{changes: %{url: url}}, conn) do
    twitter_regex = Regex.run(~r/\/(\d+)\/?$/is, url)

    archive_url =
      if !is_nil(twitter_regex) do
        [_, tweet_id] = twitter_regex
        "https://bookmark.org/twitter/" <> tweet_id
      else
        url
      end

    {a, _err} = archivebox(archive_url)

    regex_result = Regex.run(~r/archive\/(.*)/, a)
    # this gets triggered on duplicate URL and when archivebox is not running
    if is_nil(regex_result) do
      message = url <> " already exists"
      Logger.info(message)

      conn
      |> put_flash(
        :info,
        message
      )
      |> redirect(to: "/")
    else
      [_err, id] = String.split(List.first(regex_result), "archive/")
      user = conn.assigns.current_user

      Bookmark.Archives.create_archive(
        user || Bookmark.Accounts.get_user_by_email("anonymous@bookmark.org"),
        %{name: id, comment: ""}
      )

      redirect(conn, to: "/archive/" <> id)
    end
  end

  defp validate_received_url(params) do
    {%{}, %{url: :string}}
    |> Changeset.cast(params, [:url])
    |> Changeset.validate_required([:url])
    |> validate_domain()
  end

  def validate_domain(%{valid?: true} = changeset) do
    Changeset.validate_change(changeset, :url, fn _, value ->
      value
      |> check_nsfw_domain()
      |> case do
        true ->
          []

        false ->
          [{:url, "domain not allowed"}]
      end
    end)
  end

  def validate_domain(changeset), do: changeset

  defp check_nsfw_domain(url) do
    blocked_domains =
      :bookmark
      |> :code.priv_dir()
      |> Path.join("/static/blocked_domains.txt")
      |> File.read!()
      |> String.split("\n", trim: true)

    blocked_domains
    |> Enum.find(&String.contains?(url, &1))
    |> case do
      nil ->
        true

      _ ->
        false
    end
  end
end
