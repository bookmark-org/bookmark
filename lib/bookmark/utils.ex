defmodule Bookmark.Utils do
  def remove_query_string(url) do
    url
    |> URI.parse()
    |> Map.put(:query, nil)
    |> URI.to_string()
  end
end
