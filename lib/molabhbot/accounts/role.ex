defmodule Molabhbot.Accounts.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Accounts.Role


  schema "roles" do
    field :description, :string
    field :role, :string

    timestamps()
  end

  @doc false
  def changeset(%Role{} = role, attrs) do
    role
    |> cast(attrs, [:role, :description])
    |> validate_required([:role, :description])
    |> unique_constraint(:role)
  end
end
