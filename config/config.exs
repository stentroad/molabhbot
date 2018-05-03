# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :molabhbot,
  ecto_repos: [Molabhbot.Repo]

# Configures the endpoint
config :molabhbot, MolabhbotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "z/zX9TIcGc1n+qdjDKMdAQnD87cxQSGKSxtI+t2q2puNjiROSXJvYwqccHL+o6vj",
  render_errors: [view: MolabhbotWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Molabhbot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Molabhbot.Coherence.User,
  repo: Molabhbot.Repo,
  module: Molabhbot,
  web_module: MolabhbotWeb,
  router: MolabhbotWeb.Router,
  messages_backend: MolabhbotWeb.Coherence.Messages,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :registerable]

config :coherence, MolabhbotWeb.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%
