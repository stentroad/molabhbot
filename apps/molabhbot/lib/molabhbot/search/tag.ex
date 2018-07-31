defmodule Molabhbot.Search.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Search.Namespace


  schema "tags" do
    field :name, :string

    belongs_to :namespace, Namespace

    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name, :namespace_id])
    |> validate_required([:name, :namespace_id])
    |> unique_constraint(:name)
  end
end
