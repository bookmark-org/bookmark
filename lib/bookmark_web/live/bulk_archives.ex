defmodule BookmarkWeb.BulkArchivesLive do
  use BookmarkWeb, :live_view
  import BookmarkWeb.LiveHelpers
  import Phoenix.HTML.Form
  attr :field, Phoenix.HTML.FormField

  def render(assigns) do
    ~H"""
    <div style="background-color: #1e1e1e; color:white; padding: 33px; ">
      <p>Mensaje: <%= @message %></p>

      <.form for={@form} phx-submit="save">
        <.input field={@form[:url]} />
        <input type="hidden" name="user_token" value="{@user_token}" />
        <button class="add_archive_button">Add archive</button>
      </.form>
    </div>
    """
  end

  attr :field, Phoenix.HTML.FormField
  def input(assigns) do
    ~H"""
    <input
    type="url"
    id={@field.id}
    name={@field.name}
    value={@field.value}
    class="add_archive_input"
    style="background-color: white; color: black; height: 50px; margin-top: 23px; margin-bottom: 33px"
    placeholder="https://example.com (paste link here)"
    pattern="https?://.*"
    size="30"
    required
     />
    """
  end

  def handle_event("save", %{"url" => url, "user_token" => user_token}, socket) do
    current_user = Bookmark.Accounts.get_user_by_session_token(user_token)

    Bookmark.Archives.archive_url(url, current_user)
    |> IO.inspect(label: "Archive created")

    {:noreply, assign(socket, message: "Archive created!")}
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1000)

    {:ok, assign(socket, message: "Initial message", user_token: user_token,  form: to_form(%{}))}
  end

  def handle_info(:update, socket) do
    {:noreply, assign(socket, message: "Message sent from the server!: #{:rand.uniform(10)}")}
  end
end
