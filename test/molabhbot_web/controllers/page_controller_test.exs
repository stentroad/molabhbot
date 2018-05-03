defmodule MolabhbotWeb.PageControllerTest do
  use MolabhbotWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 302) # redirect to login page
  end
end
