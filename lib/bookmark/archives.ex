defmodule Bookmark.Archives do
  @moduledoc """
  The Archives context.
  """

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

    # TODO: get title from url and put it in params here

    {:ok, archive} =
      %Archive{}
      |> Archive.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert()

    add_summary(archive)
  end

  def add_summary(archive) do
    {:ok, summary} = get_summary(archive)

    archive
    |> Archive.changeset(%{summary: summary})
    |> Repo.update()
  end

  def get_summary(archive) do
    pdf_path(archive)
    |> Bookmark.Summarize.get_summary()
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
end
