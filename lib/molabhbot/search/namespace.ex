defmodule Molabhbot.Search.Namespace do
  use Ecto.Schema
  import Ecto.Changeset


  schema "namespaces" do
    field :ns, :string

    timestamps()
  end

  @doc false
  def changeset(namespace, attrs) do
    namespace
    |> cast(attrs, [:ns])
    |> validate_required([:ns])
    |> unique_constraint(:ns)
  end
end
