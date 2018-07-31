defmodule Molabhbot.Application do
  @moduledoc """
  The Mobot Application Service.

  The mobot system business domain lives in this application.

  Exposes API to clients such as the `MobotWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Molabhbot.Repo, []),
      worker(Molabhbot.WikiLinks, []),
      worker(Molabhbot.Scheduler, []),
    ], strategy: :one_for_one, name: Molabhbot.Supervisor)
  end
end
