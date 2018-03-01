defmodule Molabhbot.Telegram do
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Message
  alias Molabhbot.Telegram.Inline
  alias Molabhbot.Telegram.Reply
  alias Molabhbot.Telegram.Command
  alias Molabhbot.Telegram.Callback

  def handle_new_message(%{"message" => msg}), do: process_message_and_maybe_respond(msg)
  def handle_new_message(%{"edited_message" => msg}), do: process_message_and_maybe_respond(msg)
  def handle_new_message(%{"inline_query" => _} = params), do: Inline.process_inline_query(params)
  def handle_new_message(%{"callback_query" => _} = params), do: Callback.process_callback_query(params)

  def process_message_and_maybe_respond(msg) do
    if response_text = process_message(msg) do
      respond_to_msg(response_text, msg)
    end
  end

  def process_message(%{"entities" => _} = msg), do: Command.process_bot_cmds(msg)
  def process_message(%{"new_chat_members" => _} = msg), do: Welcome.welcome_new_users(msg)
  def process_message(%{"text" => _} = msg), do: process_text_msg(msg)
  #def process_message(%{"left_chat_member" => _}), do: nil
  def process_message(msg) do
    IO.inspect msg, label: "unhandled message:"
    nil
  end

  def process_text_msg(msg) do
    {cmd, args} = split_cmd_args(msg["text"])
    # try it as a command
    Command.process_cmd("/" <> cmd, args)
  end

  def respond_to_msg(response_text, msg) do
    response_text
    |> Message.chat_message_reply(msg)
    |> Reply.post_reply("sendMessage")
    |> IO.inspect(label: "telegram post")
  end

  def split_cmd_args(cmdline) do
    [cmd | args] = String.split(cmdline," ")
    {cmd, args}
  end

end
