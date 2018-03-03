defmodule Molabhbot.Chat do
  use GenStateMachine, callback_mode: :state_functions
  alias Molabhbot.Telegram.Build
  alias Molabhbot.Telegram.Reply

  def init(%{chat_id: chat_id} = initial_data) do
    :gproc.reg({:n,:l,{:chat,:event,chat_id}})
    {:ok, :started, initial_data}
  end

  def started({:call, from}, {:new_msg, msg}, data) do
    "Please enter event telegra.ph URL?"
    |> Build.chat_message(msg,%{force_reply: true})
    |> Reply.post_reply("sendMessage")
    {:next_state, :asked_for_telegraph_url, data, [{:reply, from, :ok}]}
  end

  def asked_for_telegraph_url({:call, from}, {:new_msg, msg}, data) do
    IO.inspect msg, label: "telegraph url"
    url = msg["text"]
    fuzzyurl = url && Fuzzyurl.from_string(url)
    cond do
      fuzzyurl.hostname == "telegra.ph" ->
        "Ok, got it thanks!"
        |> Build.chat_message(msg,%{force_reply: true})
        |> Reply.post_reply("sendMessage")
        # fetch the url
        url
        |> fetch_html()
        |> parse_event_data()
        |> IO.inspect(label: "telegraph meta")

        # UPTO: now do something with the meta data

        # %{data | telegram_url = text }
        {:stop_and_reply, :normal, [{:reply, from, :ok}]}
      true ->
        "Sorry, I don't understand.  Please Enter a valid event telegra.ph URL?"
        |> Build.chat_message(msg,%{force_reply: true})
        |> Reply.post_reply("sendMessage")
        {:next_state, :asked_for_telegraph_url, data, [{:reply, from, :ok}]}
    end
  end

  defp fetch_html(url) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(url, [], follow_redirect: true)
    body
  end

  defp parse_event_data(body) do
    metas = Floki.find(body, "meta[property]")
    for {"meta", [{"property",prop},{"content",content}],_} <- metas, is_wanted_meta?(prop), into: %{}, do: {prop,content}
  end

  defp is_wanted_meta?("og:title"), do: true
  defp is_wanted_meta?("og:description"), do: true
  defp is_wanted_meta?("article:author"), do: true
  defp is_wanted_meta?("article:published_time"), do: true
  defp is_wanted_meta?("article:modified_time"), do: true
  defp is_wanted_meta?(_), do: false

  def ensure_chat_started(%{"chat" => %{"id" => chat_id}} = msg) do
    IO.inspect chat_id, label: "start process for chat id"

    case :gproc.where({:n,:l,{:chat,:event,chat_id}}) do
      :undefined ->
        initial_data = %{first_msg: msg, chat_id: chat_id, telegram_url: nil}
        GenStateMachine.start(__MODULE__, initial_data)
      pid when is_pid(pid) ->
        {:ok, pid}
    end
  end

  def new_msg(%{"chat" => %{"id" => chat_id}} = msg) do
    case :gproc.where({:n,:l,{:chat, :event, chat_id}}) do
      pid when is_pid(pid) ->
        GenStateMachine.call(pid, {:new_msg, msg})
    end
  end

  def already_chatting?(chat_id) do
    is_pid(:gproc.where({:n,:l,{:chat, :event, chat_id}}))
  end
end
