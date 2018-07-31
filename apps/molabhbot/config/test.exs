use Mix.Config

# Configure your database
config :molabhbot, Molabhbot.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "molabhbot_test",
  hostname: "molabhbotdb.local",
  pool: Ecto.Adapters.SQL.Sandbox
