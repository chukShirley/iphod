defmodule Iphod.MonthTest do
  use Iphod.ModelCase

  alias Iphod.Month

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Month.changeset(%Month{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Month.changeset(%Month{}, @invalid_attrs)
    refute changeset.valid?
  end
end
