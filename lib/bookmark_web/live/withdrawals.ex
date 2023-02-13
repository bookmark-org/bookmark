defmodule BookmarkWeb.WithdrawalsLive do
  alias Bookmark.Withdrawals
  alias Bookmark.Accounts
  use BookmarkWeb, :live_view
  require Logger

  def render(assigns) do
    ~H"""
      <div class="grid">
          <div>
            coming soon... 
          </div>

          <form phx-submit="pay" >
            <label>Bolt 11 invoice:</label>
            <input type="text" placeholder="invoice" name="bolt11_invoice"/>
            <button>Pay Invoice</button>
          </form>
      </div>
    """
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    if connected?(socket) do
      user = Accounts.get_user_by_session_token(user_token)
      {:ok, assign(socket, current_user: user)}
    else
      {:ok, socket}
    end
  end

  def mount(_params, _session, socket) do
    redirect(socket, to: "/")
  end

  def handle_event("pay", %{"bolt11_invoice" => invoice}, socket) do
    user = socket.assigns.current_user

    case Withdrawals.pay_invoice(user.wallet_key, invoice) do
      {:ok, res} ->
        Logger.debug("Succesful response #{inspect(res)}")
        {:noreply, put_flash(socket, :info, "Invoice has been paid")}

      {:error, reason} ->
        Logger.error("Error paying invoice #{inspect(reason)}")
        {:noreply, put_flash(socket, :error, "Error paying invoice: #{inspect reason}")}
    end
  end

  def handle_event("pay", _params, socket) do
    {:noreply, socket}
  end
end
