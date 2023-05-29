defmodule BookmarkWeb.BulkArchivesLive do
  use BookmarkWeb, :live_view
  import BookmarkWeb.LiveHelpers
  import Phoenix.HTML.Form
  attr :field, Phoenix.HTML.FormField

  def render(assigns) do
    ~H"""
    <div id="main" class="m-8 grid sm:grid-cols-3 gap-1 justify-evenly">
      <!----------------------------URL List Column----------------------------------->
      <div class="col-span-1 ">
        <h3 class="text-3xl font-semibold text-white" > Archiving links: </h3>
        <%= if @urls_status do%>
          <div class="grid grid-cols-1 overflow-auto">
            <ul class="space-y-2 list-inside ">
              <%= for {url, status}  <- @urls_status do %>
                <li class="flex items-center text-md text-green-400 max-w-full">
                <%= case status do %>
                  <% "PENDING" -> %>
                    <%= BookmarkWeb.LiveHelpers.render_spinner(text:  url) %>
                  <% "FAIL" -> %>
                    <%= BookmarkWeb.LiveHelpers.render_fail(text:  url) %>
                  <% "SUCCESS" -> %>
                    <%= BookmarkWeb.LiveHelpers.render_success(text:  url) %>
                <% end %>
                </li>
              <% end %>
            </ul>
          </div>
        <% else %>
          <.form for={@form} phx-submit="save">
            <textarea placeholder="Paste your URLs here, one per line:
            https://www.example.com/
            https://www.google.com/"
            name="urls" style="height: 100px; width: 500px"></textarea>

            <input type="hidden" name="user_token" value="{@user_token}" />
            <button class="add_archive_button">Add archive</button>
          </.form>
        <% end %>
      </div>
      <!----------------------------Archive Cards Column----------------------------------->
      <div class="col-span-2">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4" style="padding: 33px;">
          <%= for a <- @archives do %>
            <%= BookmarkWeb.PageView.render_archive_card(a: a, conn: @socket) %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("save", %{"urls" => urls, "user_token" => user_token}, socket) do
    IO.puts("entro al handle event")
    url_list = String.split(urls, "\n")
    IO.inspect(urls, label: "urls")
    IO.inspect(url_list, label: "url_list")

    current_user = Bookmark.Accounts.get_user_by_session_token(user_token)

    view_pid = self()

    Process.send(view_pid, {:pending, url_list}, [:noconnect])
    spawn(fn -> Bookmark.Archives.bulk_archives(url_list, nil, view_pid) end)

    {:noreply, socket}
  end

  def mount(_params, %{"user_token" => user_token}, socket) do
    {:ok, assign(socket, archives: [], urls_status: nil, message: "", user_token: user_token,  form: to_form(%{}))}
  end

  def handle_info({:pending, url_list}, socket) do
    IO.puts("Entro al handle pending")
    map = Enum.reduce(url_list, %{}, fn key, acc ->
      Map.put(acc, key, "PENDING")
    end)
    {:noreply, assign(socket, urls_status: map)}
  end

  def handle_info({:success, archive, url}, socket) do
    IO.puts("Entro al handle success: #{archive.name}")
    {:noreply,
      assign(
        socket,
        archives: socket.assigns.archives ++ [archive],
        urls_status: Map.put(socket.assigns.urls_status, url, "SUCCESS")
      )
    }
  end

  def handle_info({:fail, url}, socket) do
    IO.puts("Entro al handle fail: #{url}")
    IO.inspect( socket.assigns.urls_status, label: "map")
    IO.inspect( Map.put(socket.assigns.urls_status, url, "FAIL"), label: "updated map")
    {:noreply,
      assign(
        socket,
        urls_status: Map.put(socket.assigns.urls_status, url, "FAIL")
      )
    }
  end

  def handle_info({_task_id, _return_value} = task_info, socket) do
    IO.inspect(task_info)
    {:noreply, socket}
  end

  def handle_info({_, _, _, _, _} = details, socket) do
    IO.inspect(details)
    {:noreply, socket}
  end
end
