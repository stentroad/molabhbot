defmodule Molabhbot.Telegram.Build do

  def chat_message(response_text, %{"chat" => %{"id" => chat_id}}, options \\ %{}) do
    %{"text": response_text,
      "chat_id": chat_id,
      "parse_mode": "Html"}
      |> Map.merge(options)
  end

  def chat_message_reply(response_text, %{"message_id" => msg_id, "chat" => %{"id" => chat_id}}, options \\ %{}) do
    %{"text": response_text,
      "chat_id": chat_id,
      "reply_to_message_id": msg_id,
      "parse_mode": "Html"}
      |> Map.merge(options)
  end

end
