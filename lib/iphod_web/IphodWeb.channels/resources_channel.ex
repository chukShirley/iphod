require IEx
require Poison
defmodule IphodWeb.ResourcesChannel do
  use IphodWeb, :channel
  
  import Ecto.Query
  alias Iphod.Resources
  alias Iphod.Repo

  def join("resources", payload, socket) do
    if authorized?(payload) do
      # send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in(request, params, socket) do
    # IO.puts ">>>>> #{request}: #{inspect params}"
    response = handle_request request, params, socket
    response
  end

  def handle_request("insult", _, socket) do
    push socket, "give_offence", %{insult: Insult.me}
    {:noreply, socket}
  end

  def handle_request("printresources", _, socket) do
    resource_list = Resources
    |> where(of_type: "print")
    |> Repo.all
    |> for_elm()
    push socket, "all_resources", %{list: resource_list}  
    {:noreply, socket}
  end

  def handle_request("inserts", _, socket) do
    resource_list = Resources
    |> where(of_type: "insert")
    |> Repo.all
    |> for_elm()
    push socket, "all_resources", %{list: resource_list}  
    {:noreply, socket}
  end

  def handle_request("linkresources", _, socket) do
    resource_list = Resources
    |> where(of_type: "link")
    |> Repo.all
    |> for_elm()
    push socket, "all_resources", %{list: resource_list}  
    {:noreply, socket}
  end

  def handle_request("humor", _, socket) do
    resource_list = Resources
    |> where(of_type: "humor")
    |> Repo.all
    |> for_elm()
    push socket, "all_resources", %{list: resource_list}  
    {:noreply, socket}
  end


  def handle_request(request, _, socket) do
    IO.puts ">>>>> INVALID REQUEST: #{request} "
    {:noreply, socket}
  end

  def for_elm(resource_list) do
    resource_list
    |> Enum.reduce( [], fn r, acc ->
        acc ++ [ %{ id:           r.id          |> Integer.to_string,
                    url:          r.url         |> nil_to_string,
                    name:         r.name        |> nil_to_string,
                    of_type:      r.of_type     |> nil_to_string,
                    description:  r.description |> nil_to_string,
                    keys:         r.keys        |> keys_to_string,
                    show:         true
                }]
      end)

  end

  def keys_to_string(nil), do: ""
  def keys_to_string(list), do: list |> Enum.join(", ")
  def nil_to_string(nil), do: ""
  def nil_to_string(s), do: s


  defp authorized?(_payload), do: true # everyone is authorized
end