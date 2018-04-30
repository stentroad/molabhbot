defmodule Molabhbot.SearchTest do
  use Molabhbot.DataCase

  alias Molabhbot.Search

  describe "tags" do
    alias Molabhbot.Search.Tag

    @valid_attrs %{name: "some name", ns: "some ns"}
    @update_attrs %{name: "some updated name", ns: "some updated ns"}
    @invalid_attrs %{name: nil, ns: nil}

    def tag_fixture(attrs \\ %{}) do
      {:ok, tag} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Search.create_tag()

      tag
    end

    test "list_tags/0 returns all tags" do
      tag = tag_fixture()
      assert Search.list_tags() == [tag]
    end

    test "get_tag!/1 returns the tag with given id" do
      tag = tag_fixture()
      assert Search.get_tag!(tag.id) == tag
    end

    test "create_tag/1 with valid data creates a tag" do
      assert {:ok, %Tag{} = tag} = Search.create_tag(@valid_attrs)
      assert tag.name == "some name"
      assert tag.ns == "some ns"
    end

    test "create_tag/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_tag(@invalid_attrs)
    end

    test "update_tag/2 with valid data updates the tag" do
      tag = tag_fixture()
      assert {:ok, tag} = Search.update_tag(tag, @update_attrs)
      assert %Tag{} = tag
      assert tag.name == "some updated name"
      assert tag.ns == "some updated ns"
    end

    test "update_tag/2 with invalid data returns error changeset" do
      tag = tag_fixture()
      assert {:error, %Ecto.Changeset{}} = Search.update_tag(tag, @invalid_attrs)
      assert tag == Search.get_tag!(tag.id)
    end

    test "delete_tag/1 deletes the tag" do
      tag = tag_fixture()
      assert {:ok, %Tag{}} = Search.delete_tag(tag)
      assert_raise Ecto.NoResultsError, fn -> Search.get_tag!(tag.id) end
    end

    test "change_tag/1 returns a tag changeset" do
      tag = tag_fixture()
      assert %Ecto.Changeset{} = Search.change_tag(tag)
    end
  end
end
