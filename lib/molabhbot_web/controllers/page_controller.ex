defmodule MolabhbotWeb.PageController do
  use MolabhbotWeb, :controller
  alias Molabhbot.Accounts

  def index(conn, _params) do
    render conn, "index.html"
  end

  def login(conn, _params) do
    render conn, "login.html", changeset: Accounts.change_user(%Accounts.User{})
  end

end
