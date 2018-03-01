defmodule Molabhbot.Telegram.Left do

  alias Molabhbot.Telegram.User

  def bye_bye(%{"left_chat_member" => user}) do
    first_name = user |> User.first_name()
    "Até Logo " <> first_name <> "!"
  end

end
