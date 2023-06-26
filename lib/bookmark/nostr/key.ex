defmodule Bookmark.Nostr.Key do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "nostr_keys" do
    field :pubkey, :string, primary_key: true
    field :name, :string
    field :relays, {:array, :string}
    belongs_to :user, Bookmark.Accounts.User
    timestamps()
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:pubkey, :name, :relays])
    |> validate_required([:pubkey, :name, :relays])
  end
end
