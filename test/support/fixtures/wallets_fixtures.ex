defmodule Bookmark.WalletsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bookmark.Wallets` context.
  """

  @doc """
  Generate a wallet.
  """
  def wallet_fixture(attrs \\ %{}) do
    {:ok, wallet} =
      attrs
      |> Enum.into(%{
        id: "some id",
        wallet_id: "some wallet_id"
      })
      |> Bookmark.Wallets.create_wallet()

    wallet
  end
end
