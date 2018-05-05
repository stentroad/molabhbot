defmodule MolabhbotWeb.PageControllerTest do
  use MolabhbotWeb.ConnCase

  @moduletag fake_login: {"testuser@example.com", "secret"}

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end

end
