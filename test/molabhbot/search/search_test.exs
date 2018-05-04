defmodule Molabhbot.SearchTest do
  use Molabhbot.DataCase

  alias Molabhbot.Search

  describe "namespaces" do
    alias Molabhbot.Search.Namespace

    @valid_attrs %{ns: "some ns"}
    @update_attrs %{ns: "some updated ns"}
    @invalid_attrs %{ns: nil}

    def namespace_fixture(attrs \\ %{}) do
      {:ok, namespace} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Search.create_namespace()

      namespace
    end

    test "list_namespaces/0 returns all namespaces" do
      namespace = namespace_fixture()
      assert Search.list_namespaces() == [namespace]
    end

    test "get_namespace!/1 returns the namespace with given id" do
      namespace = namespace_fixture()
      assert Search.get_namespace!(namespace.id) == namespace
    end

    test "create_namespace/1 with valid data creates a namespace" do
      assert {:ok, %Namespace{} = namespace} = Search.create_namespace(@valid_attrs)
      assert namespace.ns == "some ns"
    end

    test "create_namespace/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_namespace(@invalid_attrs)
    end

    test "update_namespace/2 with valid data updates the namespace" do
      namespace = namespace_fixture()
      assert {:ok, namespace} = Search.update_namespace(namespace, @update_attrs)
      assert %Namespace{} = namespace
      assert namespace.ns == "some updated ns"
    end

    test "update_namespace/2 with invalid data returns error changeset" do
      namespace = namespace_fixture()
      assert {:error, %Ecto.Changeset{}} = Search.update_namespace(namespace, @invalid_attrs)
      assert namespace == Search.get_namespace!(namespace.id)
    end

    test "delete_namespace/1 deletes the namespace" do
      namespace = namespace_fixture()
      assert {:ok, %Namespace{}} = Search.delete_namespace(namespace)
      assert_raise Ecto.NoResultsError, fn -> Search.get_namespace!(namespace.id) end
    end

    test "change_namespace/1 returns a namespace changeset" do
      namespace = namespace_fixture()
      assert %Ecto.Changeset{} = Search.change_namespace(namespace)
    end
  end
end
