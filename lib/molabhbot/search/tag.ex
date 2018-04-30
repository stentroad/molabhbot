defmodule Molabhbot.Search.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Search.Tag


  schema "tags" do
    field :name, :string
    field :ns, :string

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:ns, :name])
    |> validate_required([:ns, :name])
    |> unique_constraint(:ns)
    |> unique_constraint(:name)
  end
end
