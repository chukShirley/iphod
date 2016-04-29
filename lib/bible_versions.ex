defmodule BibleVersions do
  @url "https://bibles.org/v2/versions.js"
  @username "P7jpdltnMhHJYUlx8TZEiwvJHDvSrZ96UCV522kT" 
  @password "couldbeanything"

  def start_link do
    Agent.start_link fn -> build end, name: __MODULE__
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def id(abbreviation), do: identity[abbreviation]["id"]
  def list_all() do
    identity 
      |> Map.to_list
      |> Enum.map(fn({id, map})-> {id, map["abbreviation"], map["name"], map["lang_name_eng"]} end)
  end

  def build do
    auth = [basic_auth: {@username, @password}]
    case HTTPoison.get(@url, [{"Accept", "application/jsonrequest"}], [hackney: auth, follow_redirect: true]) do
      {:ok, resp} -> 
        body = 
          resp.body
          |> Poison.decode!
        body["response"]["versions"]
          |> Enum.reduce(%{}, fn(ver, acc)-> acc = acc |> Map.put_new(ver["abbreviation"], ver) end)
      {:error, _reason} ->
        "ESV List of Versions failed badly"
    end
  end
end