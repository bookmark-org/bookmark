defmodule BookmarkWeb.WithdrawalsLive do
  use BookmarkWeb, :live_view
  alias Bookmark.Wallets
  alias Bookmark.Withdrawals
  alias Bookmark.Accounts

  import BookmarkWeb.LiveHelpers

  require Logger

  def render(assigns) do
    ~H"""
    <div class="display-box">
      <h1 class="display-box-headline">Withdraw</h1>
          <div style="font-size: 24px; margin-bottom: 33px; ">Generate an invoice using your destination wallet. </div>

          <div><small>Total balance: <%= floor(@balance_local) %> <%= pluralize(@balance_local) %></small></div>
          <div><small><em>Transaction fee: -2 Sats</em></small></div>
          <div style="margin-bottom: 33px; "><strong>You will receive: <%= max(floor(@balance_local - 2), 0) %> <%= pluralize(@balance_local) %></strong></div>

          <form phx-submit="pay">
            <input class="donate-button" id="bolt_invoice" type="text" value={@invoice} placeholder="Paste BOLT-11 invoice (ln...)" name="bolt11_invoice" style="height: 66px; background-color: white; border-radius: 13px; margin-bottom: 13px; float: left; "/>
            <button class="donate-button scan" style="color: lightgray; float: left; margin-right: 13px; " type="button" id="scan-btn" phx-hook="ScanCode" hidden>Scan QR</button>
            <button class="donate-button withdraw" style="margin-top: 50px;" id="withdraw-btn">Withdraw</button>
          </form>

        <%= if @show_modal do %>
          <.modal>
            <div style="display: flex; justify-content: center">
              <video class="scan-video" style="width: 20em;" id="display-camera"></video>
            </div>
          </.modal>
        <% end %>
      </div>
    """
  end

  defp pluralize(amount) do
    case floor(amount) do
      1 -> "Sat"
      _amout -> "Sats"
    end
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    if connected?(socket) do
      user = Accounts.get_user_by_session_token(user_token)
      balance = Wallets.balance(user) || 0

      {:ok,
       assign(socket, current_user: user, balance_local: balance, show_modal: false, invoice: "")}
    else
      {:ok, assign(socket, balance_local: 0, show_modal: false, invoice: "")}
    end
  end

  def mount(_params, _session, socket) do
    redirect(socket, to: "/")

    {:ok, socket}
  end

  def handle_event("scan-btn-clicked", _params, socket) do
    {:noreply,
     socket
     |> assign(show_modal: true)
     |> push_event("scan-btn-clicked", %{})}
  end

  def handle_event("pay", %{"bolt11_invoice" => invoice}, socket) do
    user = socket.assigns.current_user

    withdraw(socket, user.wallet_key, invoice)
  end

  def handle_event("pay", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("modal-closed", invoice, socket) when is_binary(invoice) do
    {:noreply, assign(socket, invoice: invoice, show_modal: false)}
  end

  def handle_event("modal-closed", _params, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  defp withdraw(socket, wallet_key, invoice) do
    case Withdrawals.pay_invoice(wallet_key, invoice) do
      {:ok, res} ->
        Logger.debug("Succesful response #{inspect(res)}")
        {:noreply, put_flash(socket, :info, "Invoice has been paid") |> assign(invoice: "")}

      {:error, reason} ->
        Logger.error("Error paying invoice #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Error paying invoice: #{inspect(reason)}")}
    end
  end
end
