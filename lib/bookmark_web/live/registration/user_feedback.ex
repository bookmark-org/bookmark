defmodule BookmarkWeb.Live.Registration.UserFeedback do
  use BookmarkWeb, :live_component

  def mount(socket) do
    {:ok, assign(socket, trigger_submit: false)}
  end

  def render(assigns) do
    ~H"""
    <form
      phx-trigger-action={@trigger_submit}
      action={~p"/users/log_in?_action=registered"}
      method="post"
    >
      <%= csrf_input_tag(~p"/users/log_in?_action=registered") %>
      <input type="hidden" value={@extra[:username]} name="username" />
      <input type="hidden" value={@extra[:wallet_key]} name="wallet_key" />
      <div class="text-gray">Welcome <%= @extra[:username] %> to Bookmark</div>
      <div class="text-gray">Your wallet key is <%= @extra[:wallet_key] %></div>
      <div class="text-gray">Your lightning address is <%= @extra[:username] %>@bookmark.org</div>
      <button
        class="mt-3 bg-dark font-md border-radius-1 text-bold"
        phx-target={@myself}
        phx-click="proceed"
      >
        Got it
      </button>
    </form>
    """
  end

  def handle_event("proceed", _data, socket) do
    {:noreply, assign(socket, trigger_submit: true)}
  end
end
