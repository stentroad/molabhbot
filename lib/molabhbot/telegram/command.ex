defmodule Molabhbot.Telegram.Command do

  alias Molabhbot.Telegram
  alias Molabhbot.Telegram.Arduino

  def process_bot_cmds(msg) do
    is_bot_command? = fn(e) -> e["type"] == "bot_command" end
    bot_cmds = for e <- msg["entities"], is_bot_command?.(e), do: e
    bot_cmd_results = Enum.map(bot_cmds,fn(_) -> handle_bot_cmd(msg) end)
    Enum.join(bot_cmd_results, "\n")
  end

  def handle_bot_cmd(msg) do
    {cmd, args} = Telegram.split_cmd_args(msg["text"])
    process_cmd(cmd,args)
  end

  defp process_cmd("/help",_), do: mola_bot_help()
  defp process_cmd("/pinout",args), do: pinout(args)
  defp process_cmd(_,_), do: command_unknown()

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
