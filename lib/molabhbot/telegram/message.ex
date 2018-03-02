defmodule Molabhbot.Telegram.Message do

  alias Molabhbot.Telegram.Util
  alias Molabhbot.Telegram.Command
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Left
  alias Molabhbot.Telegram.Reply

  def process_message(msg) do
    if responses = process_specific_message(msg) do
      case responses do
        ^responses when is_list(responses) -> respond_to_msgs(responses, msg)
        ^responses when not is_list(responses) -> respond_to_msgs([responses], msg)
      end
    end
  end

  def process_specific_message(%{"new_chat_members" => _} = msg), do: Welcome.welcome_new_users(msg)
  def process_specific_message(%{"left_chat_member" => _} = msg), do: Left.bye_bye(msg)
  def process_specific_message(%{"text" => _} = msg), do: process_text_msg(msg)
  def process_specific_message(%{"chat" => _} = msg), do: process_chat(msg)
  def process_specific_message(msg) do
    IO.inspect msg, label: "unhandled message:"
    nil
  end

  def process_chat(msg) do
    if Command.message_contains_bot_commands?(msg) do
      Command.process_bot_cmds(msg)
    else
      process_text_msg(msg)
    end
  end

  def process_text_msg(msg) do
    {cmd, args} = Util.split_cmd_args(msg["text"])
    # try it as a command
    Command.process_cmd(msg, "/" <> cmd, args)
  end

  def respond_to_msgs([], _), do: nil

  def respond_to_msgs([response|rest], msg) do
    respond_to_msg(response, msg)
    respond_to_msgs(rest, msg)
  end

  def respond_to_msg(%{} = response,_) do
    response
    |> Reply.post_reply("sendMessage")
  end

end
