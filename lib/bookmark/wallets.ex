defmodule Bookmark.Wallets do
  @moduledoc """
  The Wallets context.
  """

  import Ecto.Query, warn: false
  alias Bookmark.Repo

  alias Bookmark.Wallets.Wallet

  @doc """
  Returns the list of wallets.

  ## Examples

      iex> list_wallets()
      [%Wallet{}, ...]

  """
  def list_wallets do
    Repo.all(Wallet)
  end

  def balance(nil), do: nil
  def balance(%{wallet_key: key}), do: balance(key)

  def balance(key) do
    wallet_balance(key) / 1000
  end

  @doc """
  Creates a wallet.

  ## Examples

      iex> create_wallet(%{field: value})
      {:ok, %Wallet{}}

      iex> create_wallet(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wallet(attrs \\ %{}) do
    %Wallet{}
    |> Wallet.changeset(attrs)
    |> Repo.insert()
  end

  defp wallet_balance(key) do
    {:ok, %{body: %{"balance" => balance}}} =
      Req.request(
        url: "https://legend.lnbits.com/api/v1/wallet",
        headers: [{:x_api_key, key}]
      )

    balance
  end
end
