defmodule MolabhbotWeb.NamespaceControllerTest do
  use MolabhbotWeb.ConnCase

  @moduletag fake_login: "testuser@example.com"

  alias Molabhbot.Search

  @create_attrs %{ns: "some ns"}
  @update_attrs %{ns: "some updated ns"}
  @invalid_attrs %{ns: nil}

  def fixture(:namespace) do
    {:ok, namespace} = Search.create_namespace(@create_attrs)
    namespace
  end

  describe "index" do
    test "lists all namespaces", %{conn: conn} do
      conn = get conn, namespace_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Namespaces"
    end
  end

  describe "new namespace" do
    test "renders form", %{conn: conn} do
      conn = get conn, namespace_path(conn, :new)
      assert html_response(conn, 200) =~ "New Namespace"
    end
  end

  describe "create namespace" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, namespace_path(conn, :create), namespace: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == namespace_path(conn, :show, id)

      conn = get conn, namespace_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Namespace"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, namespace_path(conn, :create), namespace: @invalid_attrs
      assert html_response(conn, 200) =~ "New Namespace"
    end
  end

  describe "edit namespace" do
    setup [:create_namespace]

    test "renders form for editing chosen namespace", %{conn: conn, namespace: namespace} do
      conn = get conn, namespace_path(conn, :edit, namespace)
      assert html_response(conn, 200) =~ "Edit Namespace"
    end
  end

  describe "update namespace" do
    setup [:create_namespace]

    test "redirects when data is valid", %{conn: conn, namespace: namespace} do
      conn = put conn, namespace_path(conn, :update, namespace), namespace: @update_attrs
      assert redirected_to(conn) == namespace_path(conn, :show, namespace)

      conn = get conn, namespace_path(conn, :show, namespace)
      assert html_response(conn, 200) =~ "some updated ns"
    end

    test "renders errors when data is invalid", %{conn: conn, namespace: namespace} do
      conn = put conn, namespace_path(conn, :update, namespace), namespace: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Namespace"
    end
  end

  describe "delete namespace" do
    setup [:create_namespace]

    test "deletes chosen namespace", %{conn: conn, namespace: namespace} do
      conn = delete conn, namespace_path(conn, :delete, namespace)
      assert redirected_to(conn) == namespace_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, namespace_path(conn, :show, namespace)
      end
    end
  end

  defp create_namespace(_) do
    namespace = fixture(:namespace)
    {:ok, namespace: namespace}
  end
end
