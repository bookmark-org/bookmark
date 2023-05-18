defmodule Bookmark.Archives.Archive do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "archives" do
    field :name, :string
    field :comment, :string
    field :title, :string
    field :summary, :string
    belongs_to :user, Bookmark.Accounts.User, foreign_key: :user_id
    timestamps()
  end

  @doc false
  def changeset(archive, attrs) do
    archive
    |> cast(attrs, [:name, :comment, :title, :summary])
    |> validate_required([:name])
  end
end
