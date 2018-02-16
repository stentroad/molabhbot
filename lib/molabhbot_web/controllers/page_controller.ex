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
    changeset = Accounts.User.login_changeset(%Accounts.User{}, params["user"])

    IO.inspect changeset, label: "login changeset"
    render conn, "index.html"
  end
end
