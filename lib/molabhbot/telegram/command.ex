defmodule Molabhbot.Telegram.Command do

  alias Molabhbot.Telegram.Util
  alias Molabhbot.Telegram.Arduino

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
    Enum.join(bot_cmd_results, "\n")
  end

  def handle_bot_cmd(msg) do
    {cmd, args} = Util.split_cmd_args(msg["text"])
    process_cmd(cmd,args)
  end

  def process_cmd("/help",_), do: mola_bot_help()
  def process_cmd("/start",_), do: start()
  def process_cmd("/pinout",args), do: pinout(args)
  def process_cmd(_,_), do: command_unknown()

  defp start() do
    """
    Welcome to Mola Bot!
    """
  end

  defp mola_bot_help() do
    """
    Mola Bot Help

    Valid commands are:
    /help
    """
  end

  defp pinout(args) do
    Arduino.arduino(Enum.join(args," "))
  end

  defp command_unknown() do
    "¯\\(°_o)/¯"
  end

end
