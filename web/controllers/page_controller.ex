defmodule Iphod.PageController do
  use Iphod.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
