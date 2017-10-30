require IEx
defmodule IphodWeb.SessionController do
  use IphodWeb, :controller

  def new(conn, _params) do
    render conn, "new.html", page_controller: "session"
  end

  def create(conn, params) do
    case Iphod.Session.login(params, Iphod.Repo) do
       {:ok, user} ->
         conn
         |> put_session(:current_user, user.id)
         |> put_flash(:info, "Logged in")
         |> logged_in(user)
       :error ->
         conn
         |> put_flash(:info, "Wrong username or password")
         |> log_fail("Error: Wrong username or password")
 
     end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/calendar")
  end

  def logged_in(conn, user) do
    package = %{
      username: user.username,
      realname: user.realname,
      email: user.email,
      description: user.description,
      token: Phoenix.Token.sign(Iphod.Endpoint, "user", user.id),
      password: "blork1",
      password_confirmation: "blork2",
      error_msg: "no error"
      }
    conn |> json( package )
  end

  def log_fail(conn, msg) do
    conn |> json( %{
      username: "",
      realname: "",
      password: "",
      password_confirmation: "",
      email: "",
      description: "",
      error_msg: msg,
      token: msg
      })
  end

end