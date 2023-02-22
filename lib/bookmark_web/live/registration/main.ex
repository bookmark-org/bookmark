defmodule BookmarkWeb.Live.Registration.Main do
  use BookmarkWeb, :live_view

  alias BookmarkWeb.Live.Registration.Username
  alias BookmarkWeb.Live.Registration.Email

  @steps %{
    :username => %{component: Username, next: :email, prev: nil},
    :email => %{component: Email, next: nil, prev: :username}
  }

  def mount(_params, _session, socket) do
    {:ok, assign(socket, steps: @steps, current: :username)}
  end

  def render(assigns) do
    ~H"""
    <h1>Heeeey</h1>

    <.live_component module={@steps[@current][:component]} id="current-step">
    </.live_component>

    <button phx-click="next">Next</button>
    <button phx-click="prev">Prev</button>
    """
  end

  def handle_event("next", _session, socket) do
    %{steps: steps, current: current} = socket.assigns

    case steps[current][:next] do
      nil -> {:noreply, socket}
      next -> {:noreply, assign(socket, current: next)}
    end
  end

  def handle_event("prev", _session, socket) do
    %{steps: steps, current: current} = socket.assigns

    case steps[current][:prev] do
      nil -> {:noreply, socket}
      prev -> {:noreply, assign(socket, current: prev)}
    end
  end
end
