defmodule Iphod.ResourcesControllerTest do
  use IphodWeb.ChannelCase

  alias Iphod.Resources
  @valid_attrs %{ description: "some content", 
                  name: "some content",  
                  url: "some content", 
                  keys: [],
                  of_type: "print",
                  key_string: "key1, key2"
                }
  @valid_query %{ description: "some content", 
                  name: "some content",  
                  url: "some content", 
                  keys: ["key1", "key2"],
                  of_type: "print"
                }
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, resources_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing resources"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, resources_path(conn, :new)
    assert html_response(conn, 200) =~ "New resources"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, resources_path(conn, :create), resources: @valid_attrs
    assert redirected_to(conn) == resources_path(conn, :index)
    assert Repo.get_by(Resources, @valid_query)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, resources_path(conn, :create), resources: @invalid_attrs
    assert html_response(conn, 200) =~ "New resources"
  end

  test "shows chosen resource", %{conn: conn} do
    resources = Repo.insert! %Resources{}
    conn = get conn, resources_path(conn, :show, resources)
    assert html_response(conn, 200) =~ "Show resources"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, resources_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    resources = Repo.insert! %Resources{}
    conn = get conn, resources_path(conn, :edit, resources)
    assert html_response(conn, 200) =~ "Edit resources"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    resources = Repo.insert! %Resources{}
    conn = put conn, resources_path(conn, :update, resources), resources: @valid_attrs
    assert redirected_to(conn) == resources_path(conn, :show, resources)
    assert Repo.get_by(Resources, @valid_query)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    resources = Repo.insert! %Resources{}
    conn = put conn, resources_path(conn, :update, resources), resources: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit resources"
  end

  test "deletes chosen resource", %{conn: conn} do
    resources = Repo.insert! %Resources{}
    conn = delete conn, resources_path(conn, :delete, resources)
    assert redirected_to(conn) == resources_path(conn, :index)
    refute Repo.get(Resources, resources.id)
  end
end
