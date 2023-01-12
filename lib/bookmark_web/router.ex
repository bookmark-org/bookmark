defmodule BookmarkWeb.Router do
  use BookmarkWeb, :router

  import BookmarkWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BookmarkWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :browser_noroot do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BookmarkWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/archive/:id", ArchiveController, :view
    post "/archive", ArchiveController, :create
    get "/profile/:username", PageController, :profile
    get "/@:username", PageController, :profile
    get "/policy", PageController, :policy
    get "/deposit", WalletController, :index
    get "/deposit/:amount", WalletController, :deposit
    get "/pay/:user_id/:amount", WalletController, :pay
    post "/pay/:invoice", WalletController, :execute
    get "/users/log_out", UserSessionController, :delete
    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  scope "/", BookmarkWeb do
    pipe_through :browser_noroot

    get "/twitter/:tweet_id", PageController, :twitter
  end

  scope "/", BookmarkWeb do
    pipe_through :api

    get "/.well-known/lnurlp/:username", WalletController, :lightning_address
    get "/api/payment_request/:username", WalletController, :payment_request
  end

  scope "/", BookmarkWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/register", UserRegistrationController, :new
    post "/users/register", UserRegistrationController, :create
    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
    get "/users/reset_password", UserResetPasswordController, :new
    post "/users/reset_password", UserResetPasswordController, :create
    get "/users/reset_password/:token", UserResetPasswordController, :edit
    put "/users/reset_password/:token", UserResetPasswordController, :update
  end

  scope "/", BookmarkWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end
end
