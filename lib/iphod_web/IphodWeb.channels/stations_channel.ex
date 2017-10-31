require IEx
defmodule IphodWeb.StationsChannel do
  use IphodWeb, :channel
  
  alias Stations

  def join("stations", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(request, params, socket) do
    response = handle_request request, params, socket
    response
  end

  def handle_request("get_station", id, socket) do
    resp = id |> Stations.for_elm
    push socket, "single_station", resp
    {:noreply, socket}
  end

  def authorized?(_payload), do: true
end