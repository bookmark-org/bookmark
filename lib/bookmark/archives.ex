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


  # Summary
  def get_summary(archive) do
    pdf_path = pdf_path(archive)

    try do
      {output, 0} = System.cmd("python3", ["summarize.py", pdf_path], cd: File.cwd!)
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
