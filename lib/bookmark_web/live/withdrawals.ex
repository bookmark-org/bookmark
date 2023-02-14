defmodule BookmarkWeb.WithdrawalsLive do
  use BookmarkWeb, :live_view
  alias Bookmark.Withdrawals
  alias Bookmark.Accounts
  alias Bookmark.Wallets

  require Logger

  def render(assigns) do
    ~H"""
      <div>
          <form phx-submit="pay" >
            <label>Bolt 11 invoice:</label>
            <input id="bolt_invoice" type="text" placeholder="invoice" name="bolt11_invoice"/>
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

  def mount(params, %{"user_token" => user_token} = session, socket) do
    if connected?(socket) do
      user = Accounts.get_user_by_session_token(user_token)
      balance = Wallets.balance(user) |> IO.inspect()
      {:ok, assign(socket, current_user: user, balance: balance)}
    else
      Logger.debug("params #{inspect(params)}")
      Logger.debug("session #{inspect(session)}")
      {:ok, socket}
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
