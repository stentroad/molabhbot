defmodule MolabhbotWeb.PageController do
  use MolabhbotWeb, :controller
  alias Molabhbot.Accounts

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show_login(conn, _params) do
    render conn, "login.html", changeset: Accounts.change_user(%Accounts.User{})
  end

  def login(conn, params) do
    IO.inspect params, label: "login params"
    user_params = params["user"]
    case Accounts.check_username_and_password(user_params["username"], user_params["password"]) do
      {:ok, user=%Accounts.User{}} ->
        conn
        |> put_flash(:info, "Login successful.")
        |> render("index.html")
      {:error,:validation_error,changeset} ->
        conn
        |> render("login.html", changeset: %{changeset | action: :login})
      {:error,_,changeset} ->
        conn
        |> put_flash(:error, "Login failed..")
        |> render("login.html", changeset: changeset)
    end
  end

end
