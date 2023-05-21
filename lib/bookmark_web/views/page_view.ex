defmodule BookmarkWeb.PageView do
  use BookmarkWeb, :view
  def render_archive_card(assigns) do
    a = assigns[:a]
    conn = assigns[:conn]
    ~E"""
    <article class="overflow-hidden rounded-lg border border-gray-100 bg-white shadow-sm dark:border-gray-800 dark:bg-black dark:shadow-gray-700/25 h-[35rem]" >
      <%= img_tag(Routes.static_path(conn, "/archive/archive/" <> a.name <> "/screenshot.png"), alt: "Archive", class: "h-56 w-full object-cover object-top")%>
      <div class="p-4 sm:p-6">
        <time class="block text-sm text-gray-400 dark:text-gray-400">
          <%= NaiveDateTime.to_string(a.updated_at) %>
        </time>
        <h3 class="mt-0.5 text-lg text-white"><%= a.title %>y</h3>
        <p class="mt-2 line-clamp-3 text-base/relaxed text-gray-400 dark:text-gray-500">
          <%= a.summary %>
        </p>
      </div>
    </article>
    """
  end
end
