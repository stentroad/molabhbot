defmodule Molabhbot.Telegram.Reply do

  def post_reply(reply, endpoint) do
    api_token = MolabhbotWeb.Endpoint.config(:telegram_api_token)
    post_result = HTTPoison.post(
      "https://api.telegram.org/bot#{api_token}/#{endpoint}",
      Poison.encode!(
        IO.inspect reply, label: "posting"
      ),
      [{"Content-type", "application/json"}]
    )
    IO.inspect post_result, label: "post result"
  end

end
