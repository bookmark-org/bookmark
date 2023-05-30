defmodule BookmarkWeb.PageView do
  use BookmarkWeb, :view
  def render_archive_card(assigns) do
    a = assigns[:a]
    conn = assigns[:conn]
    ~E"""
    <div style="background-color: white; padding: 33px; margin: 33px; border-radius: 13px">
    <a href=<%= "/archive/" <> a.name %> target="_blank">
    <h1 style="color: #ce0000; font-size: 36px"><%= a.title %></h1>
    <h2 style="font-size: 24px"><%= a.summary %></h2>
    <%= img_tag(Routes.static_path(conn, "/archive/archive/" <> a.name <> "/screenshot.png"), alt: "Archive", class: "archive-screenshot")%>
    <h3 style="color: gray; margin-top: 13px; ">Archived on <%= NaiveDateTime.to_string(a.updated_at) %></h3>
    </a>
    </div>
    """
  end
end
