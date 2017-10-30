defmodule IphodWeb.PageController do
  use IphodWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", page_controller: "page"
  end
end
