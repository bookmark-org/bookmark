defmodule BookmarkWeb.PageController do
  use BookmarkWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
