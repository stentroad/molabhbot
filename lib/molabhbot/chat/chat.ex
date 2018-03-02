defmodule Molabhbot.Chat do
  use GenStateMachine, callback_mode: :state_functions
  alias Molabhbot.Telegram.Build
  alias Molabhbot.Telegram.Reply

  def init(%{chat_id: chat_id} = initial_data) do
    :gproc.reg({:n,:l,{:chat,:event,chat_id}})
    {:ok, :started, initial_data}
  end

  def started({:call, from}, {:new_msg, msg}, data) do
    "Event telegra.ph URL?"
    |> Build.chat_message(msg,%{force_reply: true})
    |> Reply.post_reply("sendMessage")
    {:next_state, :asked_for_telegraph_url, data, [{:reply, from, :ok}]}
  end

  def asked_for_telegraph_url({:call, from}, {:new_msg, msg}, data) do
    "Sorry, I don't understand.  Please Enter a valid telegra.ph URL?"
    |> Build.chat_message(msg,%{force_reply: true})
    |> Reply.post_reply("sendMessage")
    {:next_state, :asked_for_telegraph_url, data, [{:reply, from, :ok}]}
  end

  def ensure_chat_started(%{"chat" => %{"id" => chat_id}} = msg) do
    IO.inspect chat_id, label: "start process for chat id"

    case :gproc.where({:n,:l,{:chat,:event,chat_id}}) do
      :undefined ->
        initial_data = %{first_msg: msg, chat_id: chat_id}
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
