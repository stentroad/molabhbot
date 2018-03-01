defmodule Molabhbot.Telegram.Arduino do

  def arduino(user_input) do
    get_board(user_input) |> ascii_art_arduino
  end

  def get_board(user_input) do
    cond do
      String.contains?(user_input, "uno") -> :uno
      String.contains?(user_input, "mega") -> :mega
      String.contains?(user_input, "pro-mini") -> :"pro-mini"
      String.contains?(user_input, "nano") -> :nano
      true -> :uno # uno by default, if unspecified or unmatched
    end
  end

  def ascii_art_arduino(board) do
    {:safe, safe} = (
      Application.app_dir(:molabhbot, "priv/ascii-art/#{board}.txt")
      |> File.read!()
      |> Phoenix.HTML.html_escape()
    )
    "<pre>#{safe}</pre>"
  end

end
