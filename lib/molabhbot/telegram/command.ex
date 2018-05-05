defmodule Molabhbot.Telegram.Command do

  alias Molabhbot.Telegram.Util
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Build
  alias Molabhbot.Chat
  alias Molabhbot.Wiki
  alias Molabhbot.Tag

  def message_contains_bot_commands?(msg) do
    msg["entities"] && not Enum.empty?(filter_bot_cmds(msg))
  end

  defp filter_bot_cmds(msg) do
    is_bot_command? = fn(e) -> e["type"] == "bot_command" end
    for e <- msg["entities"], is_bot_command?.(e), do: e
  end

  def process_bot_cmds(msg) do
    bot_cmds = filter_bot_cmds(msg)
    bot_cmd_results = Enum.map(bot_cmds,fn(_) -> handle_bot_cmd(msg) end)
    #Enum.join(bot_cmd_results, "\n")
    IO.inspect bot_cmd_results, label: "process_bot_cmds"
  end

  def handle_bot_cmd(msg) do
    {cmd, args} = Util.split_cmd_args(msg["text"])
    process_cmd(msg,cmd,args)
  end

  def process_cmd(msg, "/help", _), do: mola_bot_help(msg)
  def process_cmd(msg, "/start", _), do: start(msg)
  def process_cmd(msg, "/pinout", args), do: pinout(msg, args)
  def process_cmd(msg, "/event", _), do: event(msg)
  def process_cmd(msg, "/wiki", _), do: wiki(msg)
  def process_cmd(msg, "/tag", _), do: tag(msg)
  def process_cmd(msg, "/tagdone", _), do: tag(msg)
  def process_cmd(msg, _, _), do: command_unknown(msg)

  defp tag(msg) do
    Tag.ensure_started(msg)
    Tag.new_msg(msg)
    nil
  end

  defp event(msg) do
    IO.inspect Chat.ensure_chat_started(msg), label: "chat start"
    Chat.new_msg(msg)
    nil
  end

  defp start(msg) do
    """
    Welcome to Mola Bot!
    """
    |> Build.chat_message_reply(msg)
  end

  defp mola_bot_help(msg) do
    """
    Mola Bot Help

    Valid commands are:
    /help
    """
    |> Build.chat_message_reply(msg)
  end

  defp pinout(msg,args) do
    args
    |> Enum.join(" ")
    |> Arduino.arduino()
    |> Build.chat_message_reply(msg)
  end

  defp wiki(msg) do
    IO.inspect Wiki.ensure_wiki_started(msg), label: "wiki start"
    Wiki.new_msg(msg)
    IO.inspect msg, label: "wiki msg"
    nil
  end

  def command_unknown(msg) do
    "¯\\(°_o)/¯"
    |> Build.chat_message_reply(msg)
  end

end
