defmodule BookmarkWeb.Live.Registration.Email do
  use BookmarkWeb, :live_component

  def render(assigns) do
    ~H"""
    <form phx-submit={@event}>
      <label class="text-gray">Email</label>
      <input class="bg-white font-sm mt-3" name="email" placeholder="will be kept private" type="input">
      <button class="mt-3 bg-dark font-md border-radius-1 text-bold">Next</button>
    </form>
    """
  end
end
