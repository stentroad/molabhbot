defmodule Molabhbot.Telegram.Inline do

  alias Molabhbot.Telegram
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Reply

  def process_inline_query(%{"inline_query" => query}) do
    {cmd, _args} = Telegram.split_cmd_args(query["query"])
    case cmd do
      "pinout" -> reply_to_pinout(query)
      _ -> nil # FIXME: reply with help or unknown command shrug?
    end
  end

  def reply_to_pinout(query) do
    query
    |> Arduino.inline_pinout_response()
    |> Reply.post_reply("answerInlineQuery")
  end


end
