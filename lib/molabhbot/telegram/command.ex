defmodule Molabhbot.Telegram.Command do

  alias Molabhbot.Telegram.Arduino

  def mola_bot_help() do
    "Mola Bot Help

Valid commands are:
/help"
  end

  def pinout(args) do
    Arduino.arduino(Enum.join(args," "))
  end

  def command_unknown() do
    "¯\\(°_o)/¯"
  end

end
