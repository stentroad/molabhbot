defmodule Molabhbot.Telegram.Callback do

  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Reply

  def process_callback_query(params) do
    cb_query = params["callback_query"]
    arduino = cb_query["data"] |> Arduino.arduino()
    %{"callback_query_id": cb_query["id"],
      "text": arduino,
      "reply_to_message_id": cb_query["inline_message_id"]}
      |> Reply.post_reply("answerCallbackQuery")
  end

end
