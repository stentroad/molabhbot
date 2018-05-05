defmodule Molabhbot.Telegram.Arduino do

  def arduino(user_input) do
    user_input
    |> get_board()
    |> ascii_art_arduino
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

  def inline_pinout_response(query) do
    %{"inline_query_id": query["id"],
      "results": arduino_inline_results(),
      "parse_mode": "Html"}
  end

  defp arduino_inline_results() do
    for {board, title} <- arduino_defs() do
      board
      |> ascii_art_arduino()
      |> inline_query_result_article(title, "Arduino " <> title)
    end
  end

  defp arduino_defs() do
    [{:uno,"Uno"},
     {:mega,"Mega"},
     {:nano,"Nano"},
     {:"pro-mini","Pro-mini"}]
  end

  defp inline_query_result_article(message_text, title, description) do
    id = :crypto.hash(:md5, "inline_query_result_article:" <> message_text) |> Base.encode16
    %{
      "type": "article",
      "id": id,
      "title": title,
      "input_message_content": %{"message_text": message_text, "parse_mode": "Html"},
      "description": description
    }
  end

end
