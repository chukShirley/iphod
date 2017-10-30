defmodule IphodWeb.Auth do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    username = get_session(conn, :username)
    user = username && repo.get(Iphod.User, username)
    assign(conn, :current_user, user)
  end
end