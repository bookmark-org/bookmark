defmodule BookmarkWeb.WithdrawalsLive do
  use BookmarkWeb, :live_view
  require Logger

  def render(assigns) do
    ~H"""
      <div>
          <input type="text" placeholder="invoice" />
          <button phx-click="pay">Pay Invoice</button>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("pay", params, socket) do
    Logger.debug("paying #{inspect(params)}")
    {:noreply, socket}
  end
end
