defmodule Molabhbot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Accounts.User


  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password_hash])
    |> validate_required([:username, :email, :password_hash])
    |> unique_constraint(:email)
  end
end
