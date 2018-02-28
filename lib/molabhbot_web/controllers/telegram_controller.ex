defmodule MolabhbotWeb.TelegramController do
  use MolabhbotWeb, :controller
  alias Molabhbot.Telegram

  def new_message(conn, params) do
    Telegram.handle_new_message(conn, params)
  end

end
