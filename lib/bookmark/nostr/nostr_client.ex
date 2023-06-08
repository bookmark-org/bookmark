defmodule Bookmark.Nostr.Client do
  require Logger

  defp nostr_client_url() do
    System.get_env("BOOKMARK_NOSTR_CLIENT_URL") ||
      raise """
      environment variable BOOKMARK_NOSTR_CLIENT_URL is missing.
      For example: nostr-client:5005/links
      """
  end

  def get_links(nostr_key) do
    Logger.info("Executing: Nostr.Client.get_links(#{nostr_key}) ...")
    body = JSON.encode!(public_key: nostr_key)
    headers = %{"content-type" => "application/json"}
    response = Req.post(nostr_client_url(), body: body, headers: headers, receive_timeout: 10_000)
    Logger.info("Executed: Nostr.Client.get_links(#{nostr_key})")

    case response do
      {:ok, %Req.Response{status: 200, body: body}} ->
        result = body["links"]
        {:ok, result}
      _ ->
        {:error, response}
      end
  end
end
