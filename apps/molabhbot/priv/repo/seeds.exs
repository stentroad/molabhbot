# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Molabhbot.Repo.insert!(%Molabhbot.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# as suggested by coherence installation script
Molabhbot.Repo.delete_all Molabhbot.Coherence.User

Molabhbot.Coherence.User.changeset(%Molabhbot.Coherence.User{}, %{name: "Test User", email: "testuser@example.com", password: "secret", password_confirmation: "secret"})
|> Molabhbot.Repo.insert!
