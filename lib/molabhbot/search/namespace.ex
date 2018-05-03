defmodule Molabhbot.Search.Namespace do
  use Ecto.Schema
  import Ecto.Changeset
  alias Molabhbot.Search.Namespace
  alias Molabhbot.Search.Tag


  schema "namespaces" do
    field :ns, :string

    timestamps()

    has_many :tags, Tag
  end

  @doc false
  def changeset(%Namespace{} = namespace, attrs) do
    namespace
    |> cast(attrs, [:ns])
    |> validate_required([:ns])
    |> unique_constraint(:ns)
  end
end
