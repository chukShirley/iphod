defmodule IphodWeb.StationsController do
  use IphodWeb, :controller

  def index(conn, _params) do
    render conn, "index.html", page_controller: "stations"
  end

end