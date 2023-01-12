defmodule Bookmark.Wallets.Wallet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wallets" do
    field :wallet_id, :string

    timestamps()
  end

  @doc false
  def changeset(wallet, attrs) do
    wallet
    |> cast(attrs, [:wallet_id])
    |> validate_required([:wallet_id])
  end
end
