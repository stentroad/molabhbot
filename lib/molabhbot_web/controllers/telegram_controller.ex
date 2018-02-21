defmodule MolabhbotWeb.TelegramController do
  use MolabhbotWeb, :controller

  def new_message(conn, params) do
    IO.inspect params, label: "new-message params:"
    msg = params["message"] || params["edited_message"]
    cond do
      msg -> process_msg(conn, msg)
      params["inline_query"] -> process_inline_query(conn, params)
      params["callback_query"] -> process_callback_query(conn, params)
    end
  end

  def process_inline_query(conn, %{"inline_query" => query}=params) do
    [cmd | _args] = String.split(query["query"], " ")
    case cmd do
      "pinout" ->
        reply_to_pinout(conn, params)
      _ -> reply_no_content(conn)
    end
  end

  def reply_to_pinout(conn, %{"inline_query" => query}) do
    %{"inline_query_id": query["id"],
      "results": [
        inline_query_result_article(ascii_art_arduino(:uno),"Uno","Arduino Uno"),
        inline_query_result_article(ascii_art_arduino(:mega),"Mega","Arduino Mega"),
        inline_query_result_article(ascii_art_arduino(:nano),"Nano","Arduino Nano"),
        inline_query_result_article(ascii_art_arduino(:"pro-mini"),"Pro-mini","Arduino Pro-mini")
      ],
       "parse_mode": "Html"}
    |> post_reply("answerInlineQuery")
    reply_no_content(conn)
  end

  def inline_query_result_article(text, title, description) do
    id = :crypto.hash(:md5, "inline_query_result_article:" <> text) |> Base.encode16
    %{
      "type": "article",
      "id": id,
      "title": title,
      "input_message_content": %{"message_text": text, "parse_mode": "Html"},
      #"reply_markup": board_keyboard_markup(),
      "description": description
    }
  end

  def board_keyboard_markup() do
    %{
      "inline_keyboard": [[
           %{"text": "uno", "callback_data": "uno", "switch_inline_query": "/pinout uno"},
           %{"text": "mega", "callback_data": "mega", "switch_inline_query_current_chat": "/pinout mega"},
           %{"text": "nano", "callback_data": "nano"},
           %{"text": "pro-mini", "callback_data": "pro-mini"}
         ]]}
  end


  def process_callback_query(conn, params) do
    cb_query = params["callback_query"]
    board = get_board(cb_query["data"])
    %{"callback_query_id": cb_query["id"],
      "text": "a smaller message", #ascii_art_arduino(board),
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

  def process_msg(conn, msg) do
    response_msg = cond do
      msg["entities"] ->
        is_bot_command? = fn(e) -> e["type"] == "bot_command" end
        bot_cmds = for e <- msg["entities"], is_bot_command?.(e), do: e
        bot_cmd_results = Enum.map(bot_cmds,fn(_) -> handle_bot_cmd(msg) end)
        Enum.join(bot_cmd_results, "\n")
      msg["new_chat_members"] ->
        welcome_new_users(msg)
      msg["left_chat_member"] ->
        nil
      msg["text"] ->
        respond_to_pinout_msg(msg)
    end
    case response_msg do
      nil -> reply_no_content(conn)
      ^response_msg -> respond_to_msg(conn, msg, response_msg)
    end
  end

  def handle_bot_cmd(msg) do
    [cmd | args] = String.split(msg["text"]," ")
    process_cmd(cmd,args)
  end

  def process_cmd("/help",_) do
    "Mola Bot Help

     Valid commands are:
     /help "
  end

  def process_cmd("/pinout",args) do
    ascii_art_arduino(get_board(Enum.join(args," ")))
  end

  def process_cmd(_,_) do
    "commando invalido"
  end

  def welcome_new_users(msg) do
    new_chat_members = msg["new_chat_members"]
    new_user_names = Enum.map(
      new_chat_members,
      fn(%{"first_name" => first_name}) -> first_name end
    )
    welcome_text(new_user_names)
  end

  def welcome_text(users) do
    "Bem-vindo " <> user_join(users) <> "!"
  end

  def user_join([]) do
    ""
  end

  def user_join([u]) do
    u
  end

  def user_join([u1,u2]) do
    u1 <> " and " <> u2
  end

  def user_join([u|rest]) do
    u <> ", " <> user_join(rest)
  end

  def respond_to_pinout_msg(msg) do
    msg_text = msg["text"]
    ascii_art_arduino(get_board(msg_text))
  end

  def get_board(msg_txt) do
    cond do
      String.contains?(msg_txt,"uno") -> :uno
      String.contains?(msg_txt,"mega") -> :mega
      String.contains?(msg_txt,"pro-mini") -> :"pro-mini"
      String.contains?(msg_txt,"nano") -> :nano
      true -> :other
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

  def respond_to_msg(conn, msg, response_text) do
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
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:no_content, "")
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

end
