defmodule Iphod.Integration.IndexTest do
  use Iphod.IntegrationCase, async: true

  test "Basic Landing Page", %{conn: conn} do
    get(conn, calendar_path(conn, :index))
    |> follow_link("Legereme")
    |> assert_response(status: 200, path: calendar_path(conn, :index))
  end

  test "morning prayer button", %{conn: conn} do
    get(conn, calendar_path(conn, :index))
    |> follow_redirect("Morning Prayer")
    |> assert_response(status: 200, html: "Daily Morning Prayer")    
  end
end