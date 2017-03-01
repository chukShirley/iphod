defmodule Iphod.UserTest do
  use Iphod.ModelCase

  alias Iphod.User

  @valid_attrs %{ username: "some content",
                  realname: "some content",
                  encrypted_password: "some content", 
                  password: "some content",
                  password_confirmation: "some content",
                  email: "some@content", 
                  description: "some content"
                }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
