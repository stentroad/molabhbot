defmodule Molabhbot.Telegram.Command do

  alias Molabhbot.Telegram.Util
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Build

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
  def process_cmd(msg, "/pinout", args), do: pinout(msg,args)
  def process_cmd(msg, "/event", _), do: event(msg)
  def process_cmd(msg, _, _), do: command_unknown(msg)

  defp event(msg) do
    "Event title?"
    |> Build.chat_message(msg,%{force_reply: true})
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
    Arduino.arduino(Enum.join(args," "))
    |> Build.chat_message_reply(msg)
  end

  defp command_unknown(msg) do
    "¯\\(°_o)/¯"
    |> Build.chat_message_reply(msg)
  end

end
