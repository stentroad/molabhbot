defmodule Molabhbot.Telegram do
  use MolabhbotWeb, :controller
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Arduino

  def handle_new_message(conn, params) do
    IO.inspect params, label: "new-message params:"
    msg = params["message"] || params["edited_message"] 
    cond do
      msg -> process_msg(conn, msg)
      params["inline_query"] -> process_inline_query(conn, params)
      params["callback_query"] -> process_callback_query(conn, params)
    end
  end

  def process_msg(conn, msg) do
    response_text = case msg_type(msg) do
      :entities -> process_entities(msg)
      :new_chat_members -> welcome_new_users(msg)
      :left_chat_member -> nil
      :text -> process_text_msg(msg)
    end
    if response_text do
      respond_to_msg(msg, response_text)
    end
    reply_no_content(conn)
  end

  def msg_type(msg) do
    cond do
      msg["entities"] -> :entities
      msg["new_chat_members"] -> :new_chat_members
      msg["left_chat_member"] -> :left_chat_member
      msg["text"] -> :text
    end
  end

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

  def respond_to_msg(msg, response_text) do
    chat_id = msg["chat"]["id"]
    msg_id = msg["message_id"]
    api_token = MolabhbotWeb.Endpoint.config(:telegram_api_token)
    post_result = HTTPoison.post!(
      "https://api.telegram.org/bot#{api_token}/sendMessage",
      Poison.encode!(
        build_msg(
          chat_id,
          msg_id,
          response_text
        )
      ),
      [{"Content-type", "application/json"}]
    )
    IO.inspect post_result, label: "telegram post:"
  end

  def process_inline_query(conn, %{"inline_query" => query}) do
    {cmd, _args} = split_cmd_args(query["query"])
    case cmd do
      "pinout" -> reply_to_pinout(query)
      _ -> nil # FIXME: reply with help or unknown command shrug?
    end
    reply_no_content(conn)
  end

  def reply_to_pinout(query) do
    %{"inline_query_id": query["id"],
      "results": arduino_inline_results(),
      "parse_mode": "Html"}
      |> post_reply("answerInlineQuery")
  end

  def arduino_inline_results() do
    for {board, title} <- arduino_defs() do
      Arduino.ascii_art_arduino(board)
      |> inline_query_result_article(title, "Arduino " <> title)
    end
  end

  def arduino_defs() do
    [{:uno,"Uno"},
     {:mega,"Mega"},
     {:nano,"Nano"},
     {:"pro-mini","Pro-mini"}]
  end

  def inline_query_result_article(message_text, title, description) do
    id = :crypto.hash(:md5, "inline_query_result_article:" <> message_text) |> Base.encode16
    %{
      "type": "article",
      "id": id,
      "title": title,
      "input_message_content": %{"message_text": message_text, "parse_mode": "Html"},
      "description": description
    }
  end

  def process_callback_query(conn, params) do
    cb_query = params["callback_query"]
    arduino = cb_query["data"] |> Arduino.arduino()
    %{"callback_query_id": cb_query["id"],
      "text": arduino,
      "reply_to_message_id": cb_query["inline_message_id"]}
      |> post_reply("answerCallbackQuery")
    reply_no_content(conn)
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

  def handle_bot_cmd(msg) do
    {cmd, args} = split_cmd_args(msg["text"])
    process_cmd(cmd,args)
  end

  def process_cmd("/help",_) do
    "Mola Bot Help

     Valid commands are:
     /help "
  end

  def process_cmd("/pinout",args) do
    Arduino.arduino(Enum.join(args," "))
  end

  def process_cmd(_,_) do
    unknown_cmd_reply()
  end

  def welcome_new_users(msg) do
    new_chat_members = msg["new_chat_members"]
    new_user_names = Enum.map(
      new_chat_members,
      fn(%{"first_name" => first_name}) -> first_name end
    )
    Welcome.welcome_text(new_user_names)
  end

  def respond_to_pinout_msg(msg) do
    msg["text"] |> Arduino.arduino()
  end

  def build_msg(chat_id, reply_id, text) do
    IO.inspect %{"chat_id": chat_id,
                 "text": text,
                 "parse_mode": "Html",
                 "reply_to_message_id": reply_id}, label: "sending:"
  end

  def reply_no_content(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:no_content, "")
  end

  def unknown_cmd_reply do
    "¯\\(°_o)/¯"
  end
end
