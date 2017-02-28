defmodule Iphod.SessionController do
  use Iphod.Web, :controller

  def new(conn, _params) do
    render conn, "new.html", page_controller: "session"
  end

  def create(conn, %{"session" => session_params}) do
    case Iphod.Session.login(session_params, Iphod.Repo) do
      {:ok, user} ->
        conn
        |> put_session(:current_user, user.id)
        |> put_flash(:info, "Logged in")
        |> redirect(to: "/calendar")
      :error ->
        conn
        |> put_flash(:info, "Wrong username or password")
        |> render("new.html", page_controller: "session")

    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/calendar")
  end

end