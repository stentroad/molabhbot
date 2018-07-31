defmodule Molabhbot.Telegram.Inline do

  alias Molabhbot.Telegram.Util
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Reply
  alias Molabhbot.WikiLinks

  def process_inline_query(%{"inline_query" => query}) do
    {cmd, _args} = Util.split_cmd_args(query["query"])
    case cmd do
      "pinout" -> reply_to_pinout(query)
      "wiki" -> reply_to_wiki(query)
    end
  end

  def reply_to_pinout(query) do
    query
    |> Arduino.inline_pinout_response()
    |> Reply.post_reply("answerInlineQuery")
  end

  defp reply_to_wiki(query) do
    IO.inspect query, label: "wiki query"
    WikiLinks.get_links!()
    |> links_inline_response(query)
    |> Reply.post_reply("answerInlineQuery")
  end

  def links_inline_response(links, query) do
    %{"inline_query_id": query["id"],
      "results": links_inline_results(links),
      "parse_mode": "Html"}
  end

  defp links_inline_results(links) do
    for {href, desc} <- links do
      "<a href=\"#{href}\">#{desc}</a>"
      |> inline_query_result_article(desc, desc)
    end
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
