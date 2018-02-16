defmodule Molabhbot.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Accounts.User
  alias Molabhbot.Accounts.Encryption

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :username, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :password_confirmation])
    |> validate_required([:username, :email, :password, :password_confirmation])
    |> validate_length(:password, min: 5)
    |> validate_length(:username, min: 5)
    |> unique_constraint(:username)
    |> validate_confirmation(:password)
    |> validate_format(:email, ~r/@/)
    |> encrypt_password
  end

  defp encrypt_password(changeset) do
    password = get_change(changeset, :password)
    if password do
      encrypted_password = Encryption.hash_password(password)
      put_change(changeset, :password_hash, encrypted_password)
    else
      changeset
    end
  end

  def login_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 5)
    |> validate_length(:username, min: 5)
    |> unique_constraint(:username)
  end
end
