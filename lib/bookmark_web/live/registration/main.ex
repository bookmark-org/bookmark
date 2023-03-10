defmodule BookmarkWeb.Live.Registration.Main do
  use BookmarkWeb, :live_view

  alias Bookmark.Accounts
  alias BookmarkWeb.Live.Registration.Username
  alias BookmarkWeb.Live.Registration.UserFeedback

  @steps %{
    :username => %{
      component: Username,
      next: :user_feedback,
      prev: nil,
      event: "save-username"
    },
    :user_feedback => %{
      component: UserFeedback,
      next: nil,
      prev: :username,
      event: "confirm-feedback"
    }
  }

  def mount(_params, _session, socket) do
    {:ok, assign(socket, steps: @steps, current: :username, extra: %{})}
  end

  def render(assigns) do
    ~H"""
    <div class="white-bg-panel" style="padding: 16px 20px !important; min-width: 300px">
      <.live_component
        module={@steps[@current][:component]}
        event={@steps[@current][:event]}
        extra={@extra}
        id="current-step"
      >
      </.live_component>
    </div>
    """
  end

  def handle_event("save-username", %{"username" => username}, socket) do
    case Accounts.register_user_only_username(username) do
      {:ok, user} ->
        socket =
          socket
          |> assign(extra: %{username: user.username, wallet_key: user.wallet_key})
          |> load_next_step()

        {:noreply, socket}

      {:error, changeset} ->
        IO.inspect(changeset)
        {:noreply, socket}
    end
  end

  def handle_event("confirm-feedback", _data, socket) do
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
