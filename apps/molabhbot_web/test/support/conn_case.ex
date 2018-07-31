defmodule MolabhbotWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  alias Coherence.Config
  import Ecto.Query

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import MolabhbotWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint MolabhbotWeb.Endpoint
    end
  end


  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Molabhbot.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Molabhbot.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()
    conn = if tags[:fake_login] do
      fake_coherence_login(conn, tags[:fake_login])
    else
      conn
    end

    {:ok, conn: conn}
  end

  def fake_coherence_login(conn, email) do
    session_config = Plug.Session.init MolabhbotWeb.Endpoint.get_session_config()
    user_schema = Config.user_schema()
    lockable? = user_schema.lockable?()
    user = Config.repo.one(from u in user_schema, where: field(u, :email) == ^email)
    conn = conn
    |> Plug.Session.call(session_config)
    |> Plug.Conn.fetch_session()

    Config.auth_module()
    |> apply(Config.create_login(), [conn, user, [id_key: Config.schema_key()]])
    |> Coherence.SessionController.reset_failed_attempts(user, lockable?)

  end

end
