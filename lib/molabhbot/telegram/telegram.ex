defmodule Molabhbot.Telegram do
  use MolabhbotWeb, :controller
  alias Molabhbot.Telegram.Welcome
  alias Molabhbot.Telegram.Arduino
  alias Molabhbot.Telegram.Message

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
      :left_chat_member -> nil # TODO: seeya later
      :text -> process_text_msg(msg)
    end
    if response_text do
      respond_to_msg(response_text, msg)
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

  def process_inline_query(conn, %{"inline_query" => query}) do
    {cmd, _args} = split_cmd_args(query["query"])
    case cmd do
      "pinout" -> reply_to_pinout(query)
      _ -> nil # FIXME: reply with help or unknown command shrug?
    end
    reply_no_content(conn)
  end

  def reply_to_pinout(query) do
    query
    |> Arduino.inline_pinout_response()
    |> post_reply("answerInlineQuery")
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


  def reply_no_content(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:no_content, "")
  end

  def unknown_cmd_reply do
    "¯\\(°_o)/¯"
  end
end
