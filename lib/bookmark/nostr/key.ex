defmodule Bookmark.Nostr.Key do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nostr_keys" do
    field :name, :string
    field :pubkey, :string
    field :relays, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:pubkey, :name, :relays])
    |> validate_required([:pubkey, :name, :relays])
  end
end
