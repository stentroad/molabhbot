defmodule Molabhbot.Telegram do
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Message
  alias Molabhbot.Telegram.Inline
  alias Molabhbot.Telegram.Reply
  alias Molabhbot.Telegram.Command

  def handle_new_message(%{"message" => msg}), do: process_message_and_maybe_respond(msg)
  def handle_new_message(%{"edited_message" => msg}), do: process_message_and_maybe_respond(msg)
  def handle_new_message(%{"inline_query" => _} = params), do: Inline.process_inline_query(params)
  def handle_new_message(%{"callback_query" => _} = params), do: process_callback_query(params)

  def process_message_and_maybe_respond(msg) do
    if response_text = process_message(msg) do
      respond_to_msg(response_text, msg)
    end
  end

  def process_message(%{"entities" => _} = msg), do: process_bot_cmds(msg)
  def process_message(%{"new_chat_members" => _} = msg), do: Welcome.welcome_new_users(msg)
  def process_message(%{"left_chat_member" => _}), do: nil
  def process_message(%{"text" => _} = msg), do: process_text_msg(msg)

  def split_cmd_args(cmdline) do
    [cmd | args] = String.split(cmdline," ")
    {cmd, args}
  end

  def process_bot_cmds(msg) do
    is_bot_command? = fn(e) -> e["type"] == "bot_command" end
    bot_cmds = for e <- msg["entities"], is_bot_command?.(e), do: e
    bot_cmd_results = Enum.map(bot_cmds,fn(_) -> handle_bot_cmd(msg) end)
    Enum.join(bot_cmd_results, "\n")
  end

  def process_callback_query(params) do
    cb_query = params["callback_query"]
    arduino = cb_query["data"] |> Arduino.arduino()
    %{"callback_query_id": cb_query["id"],
      "text": arduino,
      "reply_to_message_id": cb_query["inline_message_id"]}
      |> Reply.post_reply("answerCallbackQuery")
  end

  def process_text_msg(msg) do
    {cmd, args} = split_cmd_args(msg["text"])
    # try it as a command
  end

  def respond_to_msg(response_text, msg) do
    response_text
    |> Message.chat_message_reply(msg)
    |> post_reply("sendMessage")
    |> IO.inspect(label: "telegram post")
    Command.process_cmd("/" <> cmd, args)
  end

  def handle_bot_cmd(msg) do
    {cmd, args} = split_cmd_args(msg["text"])
    Command.process_cmd(cmd,args)
  end

  end

end
