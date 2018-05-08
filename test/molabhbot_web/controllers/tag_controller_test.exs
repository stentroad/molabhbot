defmodule MolabhbotWeb.TagControllerTest do
  use MolabhbotWeb.ConnCase

  @moduletag fake_login: "testuser@example.com"

  alias Molabhbot.Search

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:tag) do
    {:ok, namespace} = Search.create_namespace(%{ns: "test_namespace"})
    {:ok, tag} = Search.create_tag(Enum.into(%{namespace_id: namespace.id},@create_attrs))
    tag
  end

  describe "index" do
    test "lists all tags", %{conn: conn} do
      conn = get conn, tag_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Tags"
    end
  end

  describe "new tag" do
    test "renders form", %{conn: conn} do
      conn = get conn, tag_path(conn, :new)
      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "create tag" do
    test "redirects to show when data is valid", %{conn: conn} do
      {:ok,namespace} = Search.create_namespace(%{ns: "create_tag"})
      conn = post conn, tag_path(conn, :create), tag: Enum.into(%{namespace_id: namespace.id}, @create_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == tag_path(conn, :show, id)
      conn = get conn, tag_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Tag"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, tag_path(conn, :create), tag: @invalid_attrs
      assert html_response(conn, 200) =~ "New Tag"
    end
  end

  describe "edit tag" do
    setup [:create_tag]

    test "renders form for editing chosen tag", %{conn: conn, tag: tag} do
      conn = get conn, tag_path(conn, :edit, tag)
      assert html_response(conn, 200) =~ "Edit Tag"
    end
  end

  describe "update tag" do
    setup [:create_tag]

    test "redirects when data is valid", %{conn: conn, tag: tag} do
      conn = put conn, tag_path(conn, :update, tag), tag: @update_attrs
      assert redirected_to(conn) == tag_path(conn, :show, tag)

      conn = get conn, tag_path(conn, :show, tag)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, tag: tag} do
      conn = put conn, tag_path(conn, :update, tag), tag: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Tag"
    end
  end

  describe "delete tag" do
    setup [:create_tag]

    test "deletes chosen tag", %{conn: conn, tag: tag} do
      conn = delete conn, tag_path(conn, :delete, tag)
      assert redirected_to(conn) == tag_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, tag_path(conn, :show, tag)
      end
    end
  end

  defp create_tag(_) do
    tag = fixture(:tag)
    {:ok, tag: tag}
  end
end
