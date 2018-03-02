defmodule Molabhbot.Chat do
  use GenStateMachine, callback_mode: :state_functions

  def off(:cast, :flip, data) do
    {:next_state, :on, data + 1}
  end
  def off(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def on(:cast, :flip, data) do
    {:next_state, :off, data}
  end

  def on(event_type, event_content, data) do
    handle_event(event_type, event_content, data)
  end

  def handle_event({:call, from}, :get_count, data) do
    {:keep_state_and_data, [{:reply, from, data}]}
  end

  def start_chat(msg) do
    IO.inspect msg, label: "TODO start chat"
  end
end
