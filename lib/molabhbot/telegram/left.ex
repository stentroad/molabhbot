defmodule Molabhbot.Telegram.Left do

  alias Molabhbot.Telegram.User
  alias Molabhbot.Telegram.Build

  def bye_bye(%{"left_chat_member" => user} = msg) do
    first_name = user |> User.first_name()
    "Até Logo " <> first_name <> "!"
    |> Build.chat_message_reply(msg)
  end

end
