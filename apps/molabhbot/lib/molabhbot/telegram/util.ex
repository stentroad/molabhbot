defmodule Molabhbot.Telegram.Util do

  def split_cmd_args(cmdline) do
    [cmd | args] = String.split(cmdline, " ")
    {cmd, args}
  end

end
