defmodule BookmarkWeb.WalletController do
  use BookmarkWeb, :controller

  @lnbits_payment_url "https://legend.lnbits.com/api/v1/payments"

  def get_invoice(key, amount, description) do
    desc = description |> Base.encode16()

    {:ok, body} =
      JSON.encode(
        out: "false",
        amount: amount,
        memo: "bookmark.org",
        unit: "sat",
        webhook: "https://bookmark.org/webhook",
        internal: false,
        unhashed_description: desc
      )

    {:ok, response} =
      Req.request(
        url: @lnbits_payment_url,
        headers: [{:x_api_key, key}],
        method: :post,
        body: body
      )

    Map.fetch!(response.body, "payment_request")
  end

  def get_new_wallet_key do
    {:ok, response} =
      Req.request(
        url: "https://legend.lnbits.com/wallet?nme=Bookmark",
        method: :get
      )

    key =
      String.replace(
        String.replace(
          List.first(
            Regex.run(
              ~r/Admin key: <\/strong><em>(.*)<\/em>/,
              response.body
            )
          ),
          "Admin key: </strong><em>",
          ""
        ),
        "</em>",
        ""
      )

    key
  end

  def index(conn, _params) do
    user = conn.assigns.current_user
    balance = Bookmark.Wallets.balance(user)
    title = "Balance"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "bookmark.org wallet balance"}
    ]

    render(conn, "index.html", balance: balance, meta_attrs: attrs_list, title: title)
  end

  def deposit(conn, params) do
    user = conn.assigns.current_user || Bookmark.Accounts.get_user_by_email("anonymous@bookmark.org")

    amount =
      if params["amount"] != nil do
        params["amount"]
      else
        10
      end

    display_invoice = get_invoice(user.wallet_key, amount, "deposit to " <> user.username)
    balance = Bookmark.Wallets.balance(user.wallet_key)

    title = "Deposit"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "bookmark.org deposit"}
    ]

    render(conn, "deposit.html",
      balance: balance,
      invoice: display_invoice,
      amount: amount,
      qr: qr(display_invoice),
      meta_attrs: attrs_list,
      title: title,
      user: user
    )
  end

  # receive GET request from LN wallet, send JSON response with callback info
  def lightning_address(conn, params) do
    username = params["username"]

    json(
      conn,
      %{
        callback: "https://bookmark.org/api/payment_request/" <> username,
        maxSendable: 1_000_000_000,
        minSendable: 1000,
        commentAllowed: 255,
        metadata: description(username),
        tag: "payRequest",
        status: "OK"
      }
    )
  end

  # receive GET request from LN wallet, send bech32-serialized lightning invoice response
  def payment_request(conn, params) do
    payee_user = Bookmark.Accounts.get_user_by_username(params["username"])
    amount = String.to_integer(params["amount"]) / 1000

    invoice =
      get_invoice(
        payee_user.wallet_key,
        amount,
        description(params["username"])
      )

    json(conn, %{pr: invoice, routes: []})
  end

  def qr(invoice) do
    "data:image/svg+xml;base64, " <>
      QRCode.Svg.to_base64(
        QRCode.create!(invoice, :low),
        %QRCode.SvgSettings{qrcode_color: {0, 0, 0}}
      )
  end

  def pay(conn, params) do
    payee_user = Bookmark.Accounts.get_user!(params["user_id"])
    amount = String.to_integer(params["amount"])
    display_invoice = get_invoice(payee_user.wallet_key, amount, "Pay " <> payee_user.username)
    current_user = conn.assigns.current_user

    if is_nil(current_user) do
      redirect(conn, to: "/users/log_in")
    end

    balance = Bookmark.Wallets.balance(current_user.wallet_key)

    if balance < amount do
      redirect(conn, to: "/deposit")
    end

    title = "Pay"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "bookmark.org payment"}
    ]

    render(conn, "pay.html",
      balance: balance,
      invoice: display_invoice,
      amount: amount,
      payee_username: payee_user.username,
      qr: qr(display_invoice),
      meta_attrs: attrs_list,
      title: title
    )
  end

  def execute(conn, params) do
    invoice = params["invoice"]
    {:ok, body} = JSON.encode(bolt11: invoice)

    {:ok, _response} =
      Req.request(
        url: "https://legend.lnbits.com/api/v1/payments",
        headers: [{:x_api_key, conn.assigns.current_user.wallet_key}],
        method: :post,
        body: body
      )

    redirect(conn, to: "/")
  end

  defp description(username) do
    id = id(username)
    ~s([["text/identifier", ") <> id <> ~s("], ["text/plain",") <> id <> ~s("]])
  end

  defp id(username), do: username <> "@bookmark.org"
end
