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
  Gets a single archive.

  Raises `Ecto.NoResultsError` if the Archive does not exist.

  ## Examples

      iex> get_archive!(123)
      %Archive{}

      iex> get_archive!(456)
      ** (Ecto.NoResultsError)

  """
  def get_archive!(id), do: Repo.get!(Archive, id)

  @spec create_archive(
          :invalid
          | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  @doc """
  Creates a archive.

  ## Examples

      iex> create_archive(%{field: value})
      {:ok, %Archive{}}

      iex> create_archive(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_archive(
        user,
        attrs \\ %{}
      ) do
    %Archive{}
    |> Archive.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a archive.

  ## Examples

      iex> update_archive(archive, %{field: new_value})
      {:ok, %Archive{}}

      iex> update_archive(archive, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_archive(%Archive{} = archive, attrs) do
    archive
    |> Archive.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a archive.

  ## Examples

      iex> delete_archive(archive)
      {:ok, %Archive{}}

      iex> delete_archive(archive)
      {:error, %Ecto.Changeset{}}

  """
  def delete_archive(%Archive{} = archive) do
    Repo.delete(archive)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking archive changes.

  ## Examples

      iex> change_archive(archive)
      %Ecto.Changeset{data: %Archive{}}

  """
  def change_archive(%Archive{} = archive, attrs \\ %{}) do
    Archive.changeset(archive, attrs)
  end
end
