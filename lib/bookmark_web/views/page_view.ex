defmodule BookmarkWeb.PageView do
  use BookmarkWeb, :view
  def render_archive_card(assigns) do
    a = assigns[:a]
    conn = assigns[:conn]
    ~E"""
    <table><tr><td width="50%" valign="top">
    <a href=<%= "/archive/" <> a.name %> target="_blank">
    <%= img_tag(Routes.static_path(conn, "/archive/archive/" <> a.name <> "/screenshot.png"), alt: "Archive", class: "archive-screenshot")%>
  </a>
    </td><td width="70%" valign="top">
    <a href=<%= "/archive/" <> a.name %> target="_blank">
    <div align="right">
      <h3 style="color: gray; margin-top: 13px; font-weight: normal; "><%= NaiveDateTime.to_string(a.updated_at) %></h3>
    </div>
    <h1 style="color: #ce0000; font-size: 24px"><%= a.title %></h1>
    <h2 style="font-size: 16px; color: white; font-weight: normal; "><%= a.summary %></h2>
    </a>
    </td></tr></table>
    """
  end
end
