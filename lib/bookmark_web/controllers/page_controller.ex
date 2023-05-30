defmodule BookmarkWeb.PageController do
  use BookmarkWeb, :controller

  def index(conn, _params) do
    ids = Enum.take_random(Bookmark.Archives.list_archives(), 3)

    user = conn.assigns.current_user

    attrs_list = [
      %{property: "og:title", content: "Bookmark.org"},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-preview.jpg"},
      %{property: "og:description", content: "⚡ Archive links at Bookmark.org"}
    ]

    render(conn, "index.html",
      archives: ids,
      balance: Bookmark.Wallets.balance(user),
      meta_attrs: attrs_list,
      title: "Bookmark.org - Archive links ⚡"
    )
  end

  def policy(conn, %{}) do
    user = conn.assigns.current_user

    balance = Bookmark.Wallets.balance(user.wallet_key)

    title = "Bookmark.org Policy"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "bookmark.org"}
    ]

    render(conn, "policy.html",
      balance: balance,
      title: title,
      meta_attrs: attrs_list
    )
  end

  def profile(conn, %{"username" => username}) do
    current_user = conn.assigns.current_user
    balance = if current_user do
      Bookmark.Wallets.balance(current_user.wallet_key)
    end

    user = Bookmark.Accounts.get_user_by_username(username)
    archives = Bookmark.Archives.get_archives_by_user(user)

    title = "Latest archives by " <> username <> " | bookmark.org"

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "bookmark.org"}
    ]

    render(conn, "profile.html",
      archives: archives,
      username: username,
      balance: balance,
      title: title,
      meta_attrs: attrs_list
    )
  end

  def twitter(conn, %{"tweet_id" => tweet_id}) do
    expansions = "expansions=author_id"

    tweet_fields =
      "tweet.fields=author_id,attachments,entities,id,lang,public_metrics,source,text,withheld"

    media_fields = "media.fields=preview_image_url"
    user_fields = "user.fields=profile_image_url"
    ids = "ids=" <> tweet_id

    url =
      "https://api.twitter.com/2/tweets?" <>
        expansions <>
        "&" <>
        tweet_fields <>
        "&" <>
        media_fields <>
        "&" <>
        user_fields <>
        "&" <>
        ids

    token = Application.fetch_env!(:bookmark, :twitter_token)

    title = "twitter post " <> tweet_id

    attrs_list = [
      %{property: "og:title", content: title},
      %{property: "og:image", content: "https://bookmark.org/images/bookmark-logo-wide.png"},
      %{property: "og:description", content: "bookmark.org"}
    ]

    {:ok, response} = Req.get(url, auth: {:bearer, token})

    data = response.body["data"]
    includes = response.body["includes"]

    %{"users" => users} = includes

    [
      %{
        "id" => user_id,
        "name" => user_full_name,
        "profile_image_url" => user_profile_image_url,
        "username" => username
      }
    ] = users

    [
      %{
        "author_id" => tweet_author_id,
        "lang" => tweet_lang,
        "public_metrics" => tweet_public_metrics,
        "source" => tweet_source,
        "text" => tweet_text
      }
    ] = data

    %{
      "like_count" => tweet_likes,
      "quote_count" => tweet_quotes,
      "reply_count" => tweet_replies,
      "retweet_count" => tweet_retweets
    } = tweet_public_metrics

    timestamp = DateTime.utc_now()

    render(conn, "twitter.html",
      timestamp: timestamp,
      tweet_id: tweet_id,
      title: title,
      meta_attrs: attrs_list,
      tweet_author_id: tweet_author_id,
      tweet_lang: tweet_lang,
      tweet_source: tweet_source,
      tweet_text: tweet_text,
      tweet_user_id: user_id,
      tweet_user_full_name: user_full_name,
      tweet_user_profile_image_url: user_profile_image_url,
      tweet_username: username,
      tweet_likes: tweet_likes,
      tweet_quotes: tweet_quotes,
      tweet_replies: tweet_replies,
      tweet_retweets: tweet_retweets,
      tweet_archive_hash:
        :crypto.hash(:sha256, to_string(timestamp)) |> Base.encode16() |> String.downcase()
    )
  end
end
