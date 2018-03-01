defmodule Molabhbot.Telegram.Welcome do

  def welcome_text(users) do
    {phrase, punctuation} = random_welcome_message()
    phrase <> " " <> user_join(users) <> punctuation
  end

  defp random_welcome_message() do
    [
      {"O que que pega", "?"},
      {"Teje em casa,", "!"},
      {"Salve,", "!"},
      {"Boas vindas,", "!"},
      {"Seja bem-vinde,", "!"}
    ] |> Enum.random
  end

  defp user_join([]) do
    ""
  end

  defp user_join([u]) do
    u
  end

  defp user_join([u1,u2]) do
    u1 <> " e " <> u2
  end

  defp user_join([u|rest]) do
    u <> ", " <> user_join(rest)
  end

end
