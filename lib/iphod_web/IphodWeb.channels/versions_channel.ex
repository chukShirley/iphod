require IEx
require Poison
defmodule IphodWeb.VersionsChannel do
  use IphodWeb, :channel

  def join("versions", payload, socket) do
    if authorized?(payload) do
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    list = BibleVersions.list_all
      |> Enum.map( fn({id, abbr, name, lang})-> 
          using = if abbr == "ESV", do: true, else: false
          %{id: id, abbr: abbr, name: name, lang: lang, show: true, selected: using}
        end)
      |> Enum.sort(&(&1.lang < &2.lang))
    push socket, "all_versions", %{list: list}
    {:noreply, socket}
  end

  def handle_in("request_list", _, socket), do: handle_info :after_join, socket

  defp authorized?(_payload), do: true # everyone is authorized
end