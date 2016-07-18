defmodule Iphod.MonthControllerTest do
  use Iphod.ConnCase

  alias Iphod.Month
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, month_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing months"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, month_path(conn, :new)
    assert html_response(conn, 200) =~ "New month"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, month_path(conn, :create), month: @valid_attrs
    assert redirected_to(conn) == month_path(conn, :index)
    assert Repo.get_by(Month, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, month_path(conn, :create), month: @invalid_attrs
    assert html_response(conn, 200) =~ "New month"
  end

  test "shows chosen resource", %{conn: conn} do
    month = Repo.insert! %Month{}
    conn = get conn, month_path(conn, :show, month)
    assert html_response(conn, 200) =~ "Show month"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, month_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    month = Repo.insert! %Month{}
    conn = get conn, month_path(conn, :edit, month)
    assert html_response(conn, 200) =~ "Edit month"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    month = Repo.insert! %Month{}
    conn = put conn, month_path(conn, :update, month), month: @valid_attrs
    assert redirected_to(conn) == month_path(conn, :show, month)
    assert Repo.get_by(Month, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    month = Repo.insert! %Month{}
    conn = put conn, month_path(conn, :update, month), month: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit month"
  end

  test "deletes chosen resource", %{conn: conn} do
    month = Repo.insert! %Month{}
    conn = delete conn, month_path(conn, :delete, month)
    assert redirected_to(conn) == month_path(conn, :index)
    refute Repo.get(Month, month.id)
  end
end
