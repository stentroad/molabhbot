defmodule Molabhbot.Telegram do

  alias Molabhbot.Telegram.Message
  alias Molabhbot.Telegram.Inline
  alias Molabhbot.Telegram.Callback
  alias Molabhbot.Telegram.Message

  def handle_new_message(%{"message" => msg}), do: Message.process_message(msg)
  def handle_new_message(%{"edited_message" => msg}), do: Message.process_message(msg)
  def handle_new_message(%{"inline_query" => _} = params), do: Inline.process_inline_query(params)
  def handle_new_message(%{"callback_query" => _} = params), do: Callback.process_callback_query(params)

end
