defmodule Molabhbot.Telegram.Message do

  alias Molabhbot.Telegram.Util
  alias Molabhbot.Telegram.Command
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Left
  alias Molabhbot.Telegram.Reply

  def process_message(msg) do
    if response_text = process_specific_message(msg) do
      respond_to_msg(response_text, msg)
    end
  end

  def process_specific_message(%{"entities" => _} = msg), do: Command.process_bot_cmds(msg)
  def process_specific_message(%{"new_chat_members" => _} = msg), do: Welcome.welcome_new_users(msg)
  def process_specific_message(%{"left_chat_member" => _} = msg), do: Left.bye_bye(msg)
  def process_specific_message(%{"text" => _} = msg), do: process_text_msg(msg)
  def process_specific_message(msg) do
    IO.inspect msg, label: "unhandled message:"
    nil
  end

  def process_text_msg(msg) do
    {cmd, args} = Util.split_cmd_args(msg["text"])
    # try it as a command
    Command.process_cmd("/" <> cmd, args)
  end

  def respond_to_msg(response_text, msg) do
    response_text
    |> chat_message_reply(msg)
    |> Reply.post_reply("sendMessage")
    |> IO.inspect(label: "telegram post")
  end

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
                 "reply_to_message_id": reply_id}, label: "chat_message_reply:"
  end

end
