defmodule Bookmark.Utils do
  def remove_query_string(url) do
    url
    |> URI.parse()
    |> Map.put(:query, nil)
    |> URI.to_string()
  end

  # Extracts the domain from a url
  # Example: www.sub1.sub2.sub3.domain.com/path -> domain.com
  def get_domain(url) do
    case URI.parse(url) do
      %{authority: nil} ->
        url

      %{authority: host} ->
        # sub1.sub2.sub3.domain.com -> 3
        subdomains = (host |> String.split(".") |> length()) - 2
        if subdomains >= 1 do
          subdomains = String.split(host, ".", parts: subdomains + 1)
          List.last(subdomains)
        else
          host
        end
    end
  end
end
