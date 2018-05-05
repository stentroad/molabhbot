defmodule Molabhbot.Wiki do
  use GenStateMachine, callback_mode: :state_functions
  alias Molabhbot.Telegram.Build
  alias Molabhbot.Telegram.Reply
  alias Molabhbot.WikiLinks

  def init(%{chat_id: chat_id} = initial_data) do
    :gproc.reg({:n,:l,{:chat,:event,chat_id}})
    {:ok, :started, initial_data}
  end

  def started({:call, from}, {:new_msg, msg}, data) do
    IO.inspect msg, label: "telegraph url"

    "Fetching wiki links..."
    |> Build.chat_message(msg)
    |> Reply.post_reply("sendMessage")

    WikiLinks.get_links!()
    |> links_to_html()
    |> Enum.join("\n")
    |> IO.inspect(label: "message links")
    |> Build.chat_message(msg)
    |> Reply.post_reply("sendMessage")

    {:next_state, :started, data, [{:reply, from, :ok}]}
  end

  def ensure_wiki_started(%{"chat" => %{"id" => chat_id}} = msg) do
    IO.inspect chat_id, label: "start process for chat id"

    case :gproc.where({:n, :l, {:chat, :event, chat_id}}) do
      :undefined ->
        initial_data = %{first_msg: msg, chat_id: chat_id, telegram_url: nil}
        GenStateMachine.start(__MODULE__, initial_data)
      pid when is_pid(pid) ->
        {:ok, pid}
    end
  end

  def new_msg(%{"chat" => %{"id" => chat_id}} = msg) do
    case :gproc.where({:n, :l, {:chat, :event, chat_id}}) do
      pid when is_pid(pid) ->
        GenStateMachine.call(pid, {:new_msg, msg})
    end
  end

  def already_chatting?(chat_id) do
    is_pid(:gproc.where({:n, :l, {:chat, :event, chat_id}}))
  end

  defp links_to_html(links) do
    for {href, desc} <- links, do: "<a href=\"#{href}\">#{desc}</a>"
  end
end
