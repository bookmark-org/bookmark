defmodule BookmarkWeb.Live.Registration.Main do
  use BookmarkWeb, :live_view

  alias BookmarkWeb.Live.Registration.Username
  alias BookmarkWeb.Live.Registration.Email

  @steps %{
    :username => %{component: Username, next: :email, prev: nil, event: "save-username"},
    :email => %{component: Email, next: nil, prev: :username, event: "save-email"}
  }

  def mount(_params, _session, socket) do
    {:ok, assign(socket, steps: @steps, current: :username, form_data: %{})}
  end

  def render(assigns) do
    ~H"""
    <div class="white-bg-panel" style="padding: 16px 20px !important; min-width: 300px">
      <.live_component module={@steps[@current][:component]} event={@steps[@current][:event]} id="current-step">
      </.live_component>
    </div>
    """
  end

  def handle_event("save-username", %{"username" => username}, socket) do
    %{steps: steps, current: current, form_data: form_data} = socket.assigns

    socket = socket |> assign(form_data: Map.put(form_data, "username", username))

    case steps[current][:next] do
      nil -> {:noreply, socket}
      next -> {:noreply, assign(socket, current: next)}
    end
  end

  def handle_event("save-email", %{"email" => email}, socket) do
    IO.inspect(socket.assigns.form_data, label: "before email")
    %{steps: steps, current: current, form_data: form_data} = socket.assigns

    socket = socket |> assign(form_data: Map.put(form_data, "email", email))

    IO.inspect(socket.assigns.form_data, label: "after email")

    case steps[current][:next] do
      nil -> {:noreply, socket}
      next -> {:noreply, assign(socket, current: next)}
    end
  end
end
