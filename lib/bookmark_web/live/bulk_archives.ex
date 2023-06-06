defmodule BookmarkWeb.BulkArchivesLive do
  use BookmarkWeb, :live_view
  attr :field, Phoenix.HTML.FormField
  require Logger

  def render(assigns) do
    ~H"""
    <div class="display-box">
      <h1 class="display-box-headline">Bulk archives</h1>
      <!----------------------------URL List Column----------------------------------->
        <%= if @urls_status do%>
            <ul class="space-y-2 list-inside ">
              <%= for {url, status}  <- @urls_status do %>
                <li class="flex items-center text-md text-green-400 max-w-full">
                <%= case status do %>
                  <% %{status: "PENDING"} -> %>
                    <%= BookmarkWeb.LiveHelpers.render_spinner(text:  url) %>
                  <% %{status: "FAIL", error: error} -> %>
                    <%= BookmarkWeb.LiveHelpers.render_fail(text:  url <> " (#{error})") %>
                  <% %{status: "SUCCESS"} -> %>
                    <%= BookmarkWeb.LiveHelpers.render_success(text:  url) %>
                <% end %>
                </li>
              <% end %>
            </ul>
        <% else %>
          <.form for={@form} phx-submit="save">
            <textarea placeholder="Paste your URLs here, one per line:
            https://www.example.com/
            https://www.google.com/"
            name="urls" style="height: 100px; width: 500px"></textarea>

            <button class="donate-button">Bulk archive</button>
          </.form>
        <% end %>
      <!----------------------------Archive Cards Column----------------------------------->
      <div>
        <%= for a <- @archives do %>
          <%= BookmarkWeb.PageView.render_archive_card(a: a, conn: @socket) %>
        <% end %>
      </div>
    </div>
    """
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    {:ok, assign(socket, archives: [], urls_status: nil, user_token: user_token, form: to_form(%{}))}
  end

  def handle_event("save", %{"urls" => urls}, socket) do
    user_token = socket.assigns.user_token
    current_user = Bookmark.Accounts.get_user_by_session_token(user_token)
    url_list = String.split(urls, "\n")

    Logger.info("handle_event(save). current_user: #{inspect(current_user)} url_list: #{inspect(url_list)}")

    view_pid = self()

    Process.send(view_pid, {:pending, url_list}, [:noconnect])
    spawn(fn -> Bookmark.Archives.bulk_archives(url_list, current_user, view_pid) end)

    {:noreply, socket}
  end

  def handle_info({:pending, url_list}, socket) do
    Logger.info("handle_info(:pending). url_list: #{inspect(url_list)}")
    map = Enum.reduce(url_list, %{}, fn key, acc ->
      Map.put(acc, key, %{status: "PENDING"})
    end)
    {:noreply, assign(socket, urls_status: map)}
  end

  def handle_info({:success, archive, url}, socket) do
    Logger.info("handle_info(:success). url: #{inspect(url)}")

    {:noreply,
      assign(
        socket,
        archives: socket.assigns.archives ++ [archive],
        urls_status: Map.put(socket.assigns.urls_status, url, %{status: "SUCCESS"})
      )
    }
  end

  def handle_info({:fail, url, error}, socket) do
    Logger.info("handle_info(:fail). url: #{inspect(url)}")

    error_message =
      case error do
        %{term: {:error, :already_exists}} -> "Already exists"
        %{term: {:error, :page_not_found}} -> "Page not found"
        %{term: {:error, :failed_to_parse}} -> "Invalid url format"
        %{term: {:error, :domain_not_allowed}} -> "Domain not allowed"
        %{term: {:error, :timeout_error}} -> "Timeout Error"
        %{term: {:error, :cant_be_reached}} -> "Site can’t be reached"
        _ -> "Unexpected Server Error"
      end

    {:noreply,
      assign(
        socket,
        urls_status: Map.put(socket.assigns.urls_status, url, %{status: "FAIL", error: error_message})
      )
    }
  end

  # These handle_info are necessary for handling Task.async calls
  # https://elixirforum.com/t/cant-use-task-async-within-liveview/32940/3
  def handle_info({_task_id, _return_value} = task_info, socket) do
    Logger.debug("#{inspect(task_info)}")
    {:noreply, socket}
  end

  def handle_info({_, _, _, _, _} = details, socket) do
    Logger.debug("#{inspect(details)}")
    {:noreply, socket}
  end
end
