defmodule Molabhbot.Search do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false
  alias Molabhbot.Repo
  alias Molabhbot.Search.Namespace

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

  alias Molabhbot.Search.Tag

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

  @doc """
  Ensure a tag exists in the database.
  Create it and it's associated namespace if necessary and then return the tag.
  """
  def get_or_insert_tag(namespace, tag) do
    Repo.transaction(fn ->
      n = Repo.insert!(%Namespace{ns: namespace}, on_conflict: [set: [ns: namespace]], conflict_target: :ns)
      Repo.insert!(%Tag{name: tag, namespace_id: n.id}, on_conflict: [set: [name: tag]], conflict_target: :name)
    end)
  end
end
