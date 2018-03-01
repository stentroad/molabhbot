defmodule Molabhbot.Telegram.Message do

  def chat_message_reply(response_text, msg) do
    chat_id = msg["chat"]["id"]
    msg_id = msg["message_id"]
    response_text
    |> chat_message_reply(chat_id, msg_id)

  end

  def chat_message_reply(response_text, chat_id, reply_id) do
    IO.inspect %{"chat_id": chat_id,
                 "text": response_text,
                 "parse_mode": "Html",
                 "reply_to_message_id": reply_id}, label: "sending:"
  end

end
