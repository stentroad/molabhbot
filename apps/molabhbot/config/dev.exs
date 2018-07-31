use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :molabhbot, Molabhbot,
  telegram_api_token: System.get_env("TELEGRAM_API_TOKEN"),
  secret_key_telegram: System.get_env("SECRET_KEY_TELEGRAM")

# Configure your database
config :molabhbot, Molabhbot.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "molabhbot_dev",
  hostname: "molabhbotdb.local",
  pool_size: 10,
  migration_timestamps: [type: :utc_datetime]

import_config "schedule.exs"
