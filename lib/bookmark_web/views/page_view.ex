defmodule BookmarkWeb.PageView do
  use BookmarkWeb, :view
  def render_archive_card(assigns) do
    a = assigns[:a]
    conn = assigns[:conn]
    ~E"""

    <div class="display-box">

      <a href=<%= "/archive/" <> a.name %> target="_blank">
      <%= img_tag(Routes.static_path(conn, "/archive/archive/" <> a.name <> "/screenshot.png"), alt: "Archive", class: "archive-screenshot")%>
      </a>

      <a href=<%= "/archive/" <> a.name %> target="_blank">
      <div align="right">
        <h3 style="color: gray; margin-top: 13px; font-weight: normal; "><%= NaiveDateTime.to_string(a.updated_at) %></h3>
      </div>
      <h1 style="color: #ce0000; font-size: 24px"><%= a.title %></h1>
      <h2 style="font-size: 16px; color: white; font-weight: normal; "><%= a.summary %></h2>
      </a>

    </div>
    """
  end
end
