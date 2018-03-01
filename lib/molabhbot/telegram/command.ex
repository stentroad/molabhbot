defmodule Molabhbot.Telegram.Command do

  alias Molabhbot.Telegram.Arduino

  def process_cmd("/help",_), do: mola_bot_help()
  def process_cmd("/pinout",args), do: pinout(args)
  def process_cmd(_,_), do: command_unknown()

  def mola_bot_help() do
    """
    Mola Bot Help

    Valid commands are:
    /help
    """
  end

  def pinout(args) do
    Arduino.arduino(Enum.join(args," "))
  end

  def command_unknown() do
    "¯\\(°_o)/¯"
  end

end
