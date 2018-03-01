defmodule Molabhbot.Telegram do
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Message

  def handle_new_message(%{"message" => msg}), do: process_message_and_maybe_respond(msg)
  def handle_new_message(%{"edited_message" => msg}), do: process_message_and_maybe_respond(msg)
  def handle_new_message(%{"inline_query" => _} = params), do: process_inline_query(params)
  def handle_new_message(%{"callback_query" => _} = params), do: process_callback_query(params)

  def process_message_and_maybe_respond(msg) do
    if response_text = process_message(msg) do
      respond_to_msg(response_text, msg)
    end
  end

  def process_message(%{"entities" => _} = msg), do: process_entities(msg)
  def process_message(%{"new_chat_members" => _} = msg), do: welcome_new_users(msg)
  def process_message(%{"left_chat_member" => _}), do: nil
  def process_message(%{"text" => _} = msg), do: process_text_msg(msg)

  def split_cmd_args(cmdline) do
    [cmd | args] = String.split(cmdline," ")
    {cmd, args}
  end

  def process_entities(msg) do
    is_bot_command? = fn(e) -> e["type"] == "bot_command" end
    bot_cmds = for e <- msg["entities"], is_bot_command?.(e), do: e
    bot_cmd_results = Enum.map(bot_cmds,fn(_) -> handle_bot_cmd(msg) end)
    Enum.join(bot_cmd_results, "\n")
  end

  def process_inline_query(%{"inline_query" => query}) do
    {cmd, _args} = split_cmd_args(query["query"])
    case cmd do
      "pinout" -> reply_to_pinout(query)
      _ -> nil # FIXME: reply with help or unknown command shrug?
    end
  end

  def reply_to_pinout(query) do
    query
    |> Arduino.inline_pinout_response()
    |> post_reply("answerInlineQuery")
  end

  def process_callback_query(params) do
    cb_query = params["callback_query"]
    arduino = cb_query["data"] |> Arduino.arduino()
    %{"callback_query_id": cb_query["id"],
      "text": arduino,
      "reply_to_message_id": cb_query["inline_message_id"]}
      |> post_reply("answerCallbackQuery")
  end

  def post_reply(reply, endpoint) do
    api_token = MolabhbotWeb.Endpoint.config(:telegram_api_token)
    post_result = HTTPoison.post!(
      "https://api.telegram.org/bot#{api_token}/#{endpoint}",
      Poison.encode!(
        IO.inspect reply, label: "posting:"
      ),
      [{"Content-type", "application/json"}]
    )
    IO.inspect post_result, label: "post result:"
  end

  def process_text_msg(msg) do
    {cmd, args} = split_cmd_args(msg["text"])
    # try it as a command
    process_cmd("/" <> cmd, args)
  end

  def respond_to_msg(response_text, msg) do
    response_text
    |> Message.chat_message_reply(msg)
    |> post_reply("sendMessage")
    |> IO.inspect(label: "telegram post")
  end

  def handle_bot_cmd(msg) do
    {cmd, args} = split_cmd_args(msg["text"])
    process_cmd(cmd,args)
  end

  def process_cmd("/help",_), do: Command.mola_bot_help()
  def process_cmd("/pinout",args), do: Command.pinout(args)
  def process_cmd(_,_), do: unknown_cmd_reply()


  def welcome_new_users(msg) do
    new_chat_members = msg["new_chat_members"]
    new_user_names = Enum.map(
      new_chat_members,
      fn(%{"first_name" => first_name}) -> first_name end
    )
    Welcome.welcome_text(new_user_names)
  end

  def unknown_cmd_reply do
    "¯\\(°_o)/¯"
  end
end
