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
    # IO.inspect tags, label: "TAGS ****"
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Molabhbot.Repo)
    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Molabhbot.Repo, {:shared, self()})
    end

    conn = Phoenix.ConnTest.build_conn()
    |> fake_coherence_login()

    {:ok, conn: conn}
  end

  def fake_coherence_login(conn) do
    # fake a login as 'testuser@example.com'
    session_config = Plug.Session.init(
      # copy from your endpoint.ex - plug Plug.Session
      store: :cookie,
      key: "_molabhbot_key",
      signing_salt: "2EMKa27u"
    )
    user_schema = Config.user_schema()
    lockable? = user_schema.lockable?()
    user = Config.repo.one(from u in user_schema, where: field(u, :email) == "testuser@example.com")
    conn = conn
    |> Plug.Session.call(session_config)
    |> Plug.Conn.fetch_session()

    Config.auth_module()
    |> apply(Config.create_login(), [conn, user, [id_key: Config.schema_key()]])
    |> Coherence.SessionController.reset_failed_attempts(user, lockable?)

  end

end
