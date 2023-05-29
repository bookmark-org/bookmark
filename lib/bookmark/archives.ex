defmodule Bookmark.Archives do
  @moduledoc """
  The Archives context.
  """

  require Logger
  import Ecto.Query, warn: false
  alias Bookmark.Repo
  alias Bookmark.Archives.Archive

  @doc """
  Returns the list of archives.

  ## Examples

      iex> list_archives()
      [%Archive{}, ...]

  """
  def list_archives do
    Repo.all(Archive)
  end

  def get_archive_ids_by_user(user) do
    query =
      from a in "archives",
        where: a.user_id == ^user.id,
        select: a.name

    Repo.all(query)
  end

  def get_archives_by_user(user) do
    Archive |> where(user_id: ^user.id) |> Repo.all()
  end

  def get_topn_archive_ids_by_user(user, n) do
    query =
      from a in "archives",
        where: a.user_id == ^user.id,
        select: a.name,
        limit: ^n,
        order_by: [desc: a.id]

    Repo.all(query)
  end

  @doc """
  Creates a archive.

  ## Examples

      iex> create_archive(%{field: value}, user)
      {:ok, %Archive{}}

      iex> create_archive(%{field: bad_value}, user)
      {:error, %Ecto.Changeset{}}

  """
  def create_archive(
        attrs,
        user
      ) do
    user = user || Bookmark.Accounts.get_user_by_email("anonymous@bookmark.org")

    {:ok, archive} =
      %Archive{}
      |> Archive.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert()

    add_summary(archive)
  end


  def get_title(archive_id) do
    list = index_data(archive_id)
    list["title"]
  end

  def add_summary(archive) do
    {:ok, summary} = get_summary(archive)

    archive
    |> Archive.changeset(%{summary: summary})
    |> Repo.update()
  end

  # Archivebox, create archive
  def archive_url(url, user) do
    {:ok, result} = archivebox(url)
    regex_result = Regex.run(~r/archive\/(.*)/, result)

    # this gets triggered on duplicate URL or when archivebox is not running/fails
    if is_nil(regex_result) do
      Logger.error(result)
      # TODO: Add error handling here
     {:error, :already_exists}
    else
      Logger.debug(result)
      [_err, id] = String.split(List.first(regex_result), "archive/")

      create_archive(%{name: id, comment: "", title: get_title(id)}, user)
    end
  end

  def archivebox(url) do
    Logger.info("Executing: archivebox add #{url} ...")

    body = JSON.encode!(url: url)
    headers = %{"content-type" => "application/json"}
    {:ok, res} = Req.post(archivebox_url(), body: body, headers: headers, receive_timeout: 120_000)

    Logger.info("Executed: archivebox add #{url}")

    {:ok, res.body["result"]}
  end

  defp archivebox_url() do
    System.get_env("BOOKMARK_ARCHIVEBOX_URL") ||
      raise """
      environment variable BOOKMARK_ARCHIVEBOX_URL is missing.
      For example: archivebox:5001/add
      """
  end

  # Summary
  def get_summary(archive) do
    pdf_path = pdf_path(archive)

    try do
      Logger.info("Executing: python3 summarize.py #{pdf_path} ...")
      {output, 0} = System.cmd("python3", ["summarize.py", pdf_path], cd: File.cwd!)
      Logger.info("Executed: python3 summarize.py #{pdf_path}")
      {:ok, output}
    rescue e ->
      Logger.error(e)
      {:ok, "Summary not available"}
    end
  end


  # Utils
  def pdf_path(archive) do
    directory() <> "/archive/" <> archive.name <>  "/output.pdf"
  end

  def directory do
    case Application.get_env(:bookmark, :env) do
      :prod -> Application.app_dir(:bookmark, "priv/static/archive")
      _ -> File.cwd!() <> "/priv/static/archive"
    end
  end

  def index_data(archive_id) do
    file_path = Bookmark.Archives.directory() <> "/archive/" <> archive_id
    index_json = File.read!(file_path <> "/index.json")
    JSON.decode!(index_json)
  end
end
