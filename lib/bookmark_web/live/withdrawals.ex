defmodule BookmarkWeb.WithdrawalsLive do
  use BookmarkWeb, :live_view
  alias Bookmark.Wallets
  alias Bookmark.Withdrawals
  alias Bookmark.Accounts

  require Logger

  def render(assigns) do
    ~H"""
      <div style="padding: 30px">
        <h1>Withdraw</h1>
        <div style="display: flex; justify-content: space-between">
          <div>Total:</div>
          <div><%= @balance %></div>
        </div>
        <div style="display: flex; justify-content: space-between">
          <em>Fee:</em>
          <em>-2</em>
        </div>
        <div style="display: flex; justify-content: space-between">
          <strong>Available:</strong>
          <strong><%= @balance - 2 %></strong>
        </div>
        <form phx-submit="pay" >
          <input class="pay-invoice-input" id="bolt_invoice" type="text" placeholder="bolt11 invoice" name="bolt11_invoice"/>
          <div class="grid">
            <button>Pay Invoice</button>
            <button type="button" id="scan-btn" phx-hook="ScanCode">📷 Scan</button>
          </div>
        </form>

        <div>
          <video id="display-camera"></video>
        </div>
      </div>
    """
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    if connected?(socket) do
      user = Accounts.get_user_by_session_token(user_token)
      balance = Wallets.balance(user) || 0
      {:ok, assign(socket, current_user: user, balance: balance)}
    else
      {:ok, assign(socket, balance: 0)}
    end
  end

  def mount(_params, _session, socket) do
    redirect(socket, to: "/")

    {:ok, socket}
  end

  def handle_event("pay", %{"bolt11_invoice" => invoice}, socket) do
    user = socket.assigns.current_user

    case Withdrawals.pay_invoice(user.wallet_key, invoice) do
      {:ok, res} ->
        Logger.debug("Succesful response #{inspect(res)}")
        {:noreply, put_flash(socket, :info, "Invoice has been paid")}

      {:error, reason} ->
        Logger.error("Error paying invoice #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Error paying invoice: #{inspect(reason)}")}
    end
  end

  def handle_event("pay", _params, socket) do
    {:noreply, socket}
  end
end
