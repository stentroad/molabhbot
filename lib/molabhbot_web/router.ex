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

    get "/", PageController, :index
    # add public resources below
  end

  # scope "/", MyProjectWeb do
  #   pipe_through :protected

  #   # add protected resources below
  #   resources "/admin", MyProjectWeb.PrivateController
  # end

  # old auth stuff below here

  # pipeline :authenticated do
  #   plug :ensure_authenticated
  # end

  # pipeline :api do
  #   plug :accepts, ["json"]
  #   plug :fetch_session
  # end

  # pipeline :check_telegram_key do
  #   plug :validate_telegram_key
  # end

  # scope "/login", MolabhbotWeb do
  #   pipe_through :browser

  #   get "/", PageController, :show_login
  #   post "/", PageController, :login
  # end

  # scope "/logout", MolabhbotWeb do
  #   pipe_through :browser

  #   get "/", PageController, :logout
  # end

  # scope "/", MolabhbotWeb do
  #   pipe_through :browser # Use the default browser stack
  #   pipe_through :authenticated

  #   get "/", PageController, :index
  #   resources "/roles", RoleController
  # end

  # # Other scopes may use custom stacks.
  # scope "/api", MolabhbotWeb do
  #   pipe_through :api
  #   pipe_through :authenticated

  #   resources "/users", UserController
  # end

  # scope "/telegram/:telegram_key", MolabhbotWeb do
  #   pipe_through :api
  #   pipe_through :check_telegram_key

  #   post "/", TelegramController, :new_message
  # end

  # defp validate_telegram_key(conn,_) do
  #   telegram_webhook_key = MolabhbotWeb.Endpoint.config(:secret_key_telegram)
  #   sent_key = conn.path_params["telegram_key"]
  #   if sent_key == telegram_webhook_key do
	# conn 
  #   else
  #       conn |> put_resp_content_type("text/plain")
  #            |> send_resp(401, "unauthorized") 
  #            |> halt()
  #   end
  # end

  # defp ensure_authenticated(conn,_) do
  #   user_id = Plug.Conn.get_session(conn, :user_id)
  #   IO.inspect user_id, label: "logged in user_id"
  #   if user_id do
  #     conn
  #     |> assign(:user, Molabhbot.Accounts.get_user!(user_id))
  #     |> configure_session(renew: true)
  #   else
  #     conn
  #     |> assign(:user, nil)
  #     |> redirect(to: "/login")
  #   end
  # end

end
