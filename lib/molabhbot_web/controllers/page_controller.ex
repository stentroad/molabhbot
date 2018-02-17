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
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Login successful.")
        |> redirect(to: "/")
      {:error,:validation_error,changeset} ->
        conn
        |> render("login.html", changeset: %{changeset | action: :login})
      {:error,_,changeset} ->
        conn
        |> put_flash(:error, "Login failed..")
        |> render("login.html", changeset: changeset)
    end
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> assign(:user, nil)
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/")
  end

end
