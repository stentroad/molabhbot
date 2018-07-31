defmodule MolabhbotWeb.NamespaceController do
  use MolabhbotWeb, :controller

  alias Molabhbot.Search
  alias Molabhbot.Search.Namespace

  def index(conn, _params) do
    namespaces = Search.list_namespaces()
    render(conn, "index.html", namespaces: namespaces)
  end

  def new(conn, _params) do
    changeset = Search.change_namespace(%Namespace{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"namespace" => namespace_params}) do
    case Search.create_namespace(namespace_params) do
      {:ok, namespace} ->
        conn
        |> put_flash(:info, "Namespace created successfully.")
        |> redirect(to: namespace_path(conn, :show, namespace))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    namespace = Search.get_namespace!(id)
    render(conn, "show.html", namespace: namespace)
  end

  def edit(conn, %{"id" => id}) do
    namespace = Search.get_namespace!(id)
    changeset = Search.change_namespace(namespace)
    render(conn, "edit.html", namespace: namespace, changeset: changeset)
  end

  def update(conn, %{"id" => id, "namespace" => namespace_params}) do
    namespace = Search.get_namespace!(id)

    case Search.update_namespace(namespace, namespace_params) do
      {:ok, namespace} ->
        conn
        |> put_flash(:info, "Namespace updated successfully.")
        |> redirect(to: namespace_path(conn, :show, namespace))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", namespace: namespace, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    namespace = Search.get_namespace!(id)
    {:ok, _namespace} = Search.delete_namespace(namespace)

    conn
    |> put_flash(:info, "Namespace deleted successfully.")
    |> redirect(to: namespace_path(conn, :index))
  end
end
