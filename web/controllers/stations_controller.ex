defmodule Iphod.StationsController do
  use Iphod.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", page_controller: "stations"
  end

end