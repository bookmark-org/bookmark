defmodule BookmarkWeb.Live.Registration.Main do
  use BookmarkWeb, :live_view

  alias BookmarkWeb.Live.Registration.UserFeedback
  alias BookmarkWeb.Live.Registration.Username
  alias BookmarkWeb.Live.Registration.Email

  @steps %{
    :username => %{
      component: Username,
      next: :user_feedback,
      prev: nil,
      event: "save-username"
    },
    :user_feedback => %{
      component: UserFeedback,
      next: :email,
      prev: :username,
      event: "confirm-feedback"
    },
    :email => %{
      component: Email,
      next: nil,
      prev: :user_feedback,
      event: "save-email"
    }
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
    %{form_data: form_data} = socket.assigns

    socket = socket |> assign(form_data: Map.put(form_data, "username", username))

    {:noreply, load_next_step(socket)}
  end

  def handle_event("confirm-feedback", _data, socket) do
    {:noreply, load_next_step(socket)}
  end

  def handle_event("save-email", %{"email" => email}, socket) do
    %{form_data: form_data} = socket.assigns

    socket = socket |> assign(form_data: Map.put(form_data, "email", email))

    {:noreply, load_next_step(socket)}
  end

  defp load_next_step(socket) do
    %{steps: steps, current: current} = socket.assigns

    case steps[current][:next] do
      nil -> socket
      next -> assign(socket, current: next)
    end
  end
end
