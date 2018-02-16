defmodule MolabhbotWeb.Router do
  use MolabhbotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug :ensure_authenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/login", MolabhbotWeb do
    pipe_through :browser

    get "/", PageController, :show_login
    post "/", PageController, :login
  end

  scope "/", MolabhbotWeb do
    pipe_through :authenticated
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController
    resources "/roles", RoleController
  end

  # Other scopes may use custom stacks.
  scope "/api", MolabhbotWeb do
    pipe_through :authenticated
    pipe_through :api

    resources "/api/users", UserController
  end

  defp ensure_authenticated(conn,_) do
    conn |> redirect(to: "/login")
  end

end
