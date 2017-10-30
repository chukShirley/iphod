defmodule Iphod.Session do
  alias Iphod.User

  def login(params, repo) do
    user = repo.get_by(User, username: String.downcase(params["username"]))
    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> :error
    end
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
    end
  end

  def current_user(conn) do
    get_user(Plug.Conn.get_session(conn, :current_user))
  end

  defp get_user(nil), do: nil
  defp get_user(id), do: Iphod.Repo.get(User, id)

  def logged_in?(conn), do: !!current_user(conn)
end