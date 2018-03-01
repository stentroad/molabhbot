defmodule MolabhbotWeb.TelegramController do
  use MolabhbotWeb, :controller
  alias Molabhbot.Telegram

  def new_message(conn, params) do
    Telegram.handle_new_message(params)
    reply_no_content(conn)
  end

  def reply_no_content(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:no_content, "")
  end

end
