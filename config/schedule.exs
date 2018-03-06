use Mix.Config

# quantum scheduler "cron" jobs

config :molabhbot, Molabhbot.Scheduler,
  jobs: [
    # refresh wiki links hourly
    {"0 * * * *", {Molabhbot.WikiLinks, :refresh_links, []}}
  ]
