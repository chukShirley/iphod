defmodule Iphod.ReflectionTest do
  use Iphod.ModelCase

  alias Iphod.Reflection

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reflection.changeset(%Reflection{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reflection.changeset(%Reflection{}, @invalid_attrs)
    refute changeset.valid?
  end
end
