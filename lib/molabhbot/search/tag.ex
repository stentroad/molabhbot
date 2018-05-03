defmodule Molabhbot.Search.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Search.Tag


  schema "tags" do
    field :name, :string

    belongs_to :namespace, Molabhbot.Search.Namespace

    timestamps()
  end

  @doc false
  def changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:namespace_id, :name])
    |> validate_required([:namespace_id, :name])
    |> unique_constraint(:name)
  end
end
