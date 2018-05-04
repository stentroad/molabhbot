defmodule MolabhbotWeb.Router do
  use MolabhbotWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :check_telegram_key do
    plug :validate_telegram_key
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  scope "/", MolabhbotWeb do
    pipe_through :browser

    # add public resources below
  end

  scope "/", MolabhbotWeb do
    pipe_through :protected
    # add protected resources below
    get "/", PageController, :index
    resources "/namespaces", NamespaceController
  end

  scope "/telegram/:telegram_key", MolabhbotWeb do
    pipe_through :api
    pipe_through :check_telegram_key

    post "/", TelegramController, :new_message
  end

  defp validate_telegram_key(conn,_) do
    telegram_webhook_key = MolabhbotWeb.Endpoint.config(:secret_key_telegram)
    sent_key = conn.path_params["telegram_key"]
    if sent_key == telegram_webhook_key do
	    conn
    else
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(401, "unauthorized")
      |> halt()
    end
  end

end
