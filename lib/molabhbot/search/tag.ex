defmodule Molabhbot.Search.Tag do
  use Ecto.Schema
  import Ecto.Changeset


  schema "tags" do
    field :name, :string
    field :namespace_id, :id

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
