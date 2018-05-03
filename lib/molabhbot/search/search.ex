defmodule Molabhbot.Search do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false
  alias Molabhbot.Repo
  alias Ecto.Multi

  alias Molabhbot.Search.Tag
  alias Molabhbot.Search.Namespace

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{source: %Tag{}}

  """
  def change_tag(%Tag{} = tag) do
    Tag.changeset(tag, %{})
  end

  def find_tag(ns, name) do
    Repo.one(
      from t in Tag,
      select: t.id,
      where: t.ns == ^ns,
      where: t.name == ^name
    )
  end

  @doc """
  Check tag exists, creating it if not.

  ## Examples

  iex> ensure_tag(%{field: value})
  {:ok, %Tag{}}

  iex> ensure_tag(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def find_or_create_tag(ns, name) do
    # # first we need to create or fetch the namespace id
    # # or create the namespace if it doesn't exist
    # try do
    #   # first try to create namespace and add tag in a single transaction
    #   ns_changeset =
    #     %Namespace{}
    #     |> Namespace.changeset(%{ns: ns})

    #   multi =
    #     Multi.new
    #     |> Multi.insert(:ns, ns_changeset)
    #     |> Multi.run(:tag, fn %{ns: ns} ->
    #     tag_changeset =
    #       %Tag{namespace_id: ns.id}
    #       |> Tag.changeset(%{name: name})
    #     Repo.insert(tag_changeset)
    #   end)
    #     Repo.transaction(multi)
    # rescue
    #   Sqlite.DbConnection.Error ->
    #     # presumably namespace already exists
    #     ns_id = Repo.one(
    #   from ns in Namespace,
    #   select: ns.id,
    #   where: ns.ns == ^ns
    # )
    #   %Tag{namespace_id: ns_id}
    #   |> Tag.changeset(%{name: name})
    #   |> Repo.insert!()
    # end
  end

  # try do
  #   %Tag{}
  #   |> Tag.changeset(%{ns: ns, name: name})
  #   |> Repo.insert!()
  # rescue
  #   Sqlite.DbConnection.Error -> :probably_already_exists
  # end

  # find_tag(ns, name)
def find_or_create_ns(ns) do
  %Namespace{}
  |> Ecto.Changeset.change(ns: ns)
  |> Ecto.Changeset.unique_constraint(:ns)
  |> Repo.insert
  |> case do
       {:ok, ns} -> ns
       {:error, _} -> Repo.get_by!(Namespace, ns: ns)
     end
end
  @doc """
  Returns the list of namespaces.

  ## Examples

      iex> list_namespaces()
      [%Namespace{}, ...]

  """
  def list_namespaces do
    Repo.all(Namespace)
  end

  @doc """
  Gets a single namespace.

  Raises `Ecto.NoResultsError` if the Namespace does not exist.

  ## Examples

      iex> get_namespace!(123)
      %Namespace{}

      iex> get_namespace!(456)
      ** (Ecto.NoResultsError)

  """
  def get_namespace!(id), do: Repo.get!(Namespace, id)

  @doc """
  Creates a namespace.

  ## Examples

      iex> create_namespace(%{field: value})
      {:ok, %Namespace{}}

      iex> create_namespace(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_namespace(attrs \\ %{}) do
    %Namespace{}
    |> Namespace.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a namespace.

  ## Examples

      iex> update_namespace(namespace, %{field: new_value})
      {:ok, %Namespace{}}

      iex> update_namespace(namespace, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_namespace(%Namespace{} = namespace, attrs) do
    namespace
    |> Namespace.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Namespace.

  ## Examples

      iex> delete_namespace(namespace)
      {:ok, %Namespace{}}

      iex> delete_namespace(namespace)
      {:error, %Ecto.Changeset{}}

  """
  def delete_namespace(%Namespace{} = namespace) do
    Repo.delete(namespace)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking namespace changes.

  ## Examples

      iex> change_namespace(namespace)
      %Ecto.Changeset{source: %Namespace{}}

  """
  def change_namespace(%Namespace{} = namespace) do
    Namespace.changeset(namespace, %{})
  end
end


