defmodule Iphod.ResourcesTest do
  use Iphod.ModelCase

  alias Iphod.Resources

  @valid_attrs %{description: "some content", name: "some content", url: "some content"}
  @valid_attrs %{ description: "some content", 
                  name: "some content",  
                  url: "some content", 
                  keys: [],
                  of_type: "print",
                  key_string: "key1, key2"
                }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Resources.changeset(%Resources{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Resources.changeset(%Resources{}, @invalid_attrs)
    refute changeset.valid?
  end
end
