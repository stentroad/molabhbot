defmodule Molabhbot.Search.Namespace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Search.Tag

  schema "namespaces" do
    field :ns, :string

    has_many :tags, Tag

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
