defmodule Bookmark.Withdrawals do
  @lnbits_payment_url "https://legend.lnbits.com/api/v1/payments"

  def pay_invoice(key, bolt11_invoice) do
    {:ok, body} =
      JSON.encode(
        out: "true",
        bolt11: bolt11_invoice
      )

    case Req.request(
           url: @lnbits_payment_url,
           headers: [{:x_api_key, key}],
           method: :post,
           body: body,
           receive_timeout: 60_000
         ) do
      {:ok, response} ->
        case response.status do
          201 -> {:ok, response.body}
          _status -> {:error, response.body["detail"]}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
