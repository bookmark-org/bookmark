defmodule BookmarkWeb.Live.Registration.UserFeedback do
  use BookmarkWeb, :live_component

  def render(assigns) do
    ~H"""
    <form>
      Important Info here
      <button class="mt-3 bg-dark font-md border-radius-1 text-bold" phx-click={@event}>Next</button>
    </form>
    """
  end
end
