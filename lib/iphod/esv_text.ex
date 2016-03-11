require IEx
require Logger
defmodule EsvText do
  @esvKey "10b28dac7c57fd96"

  def request(vss) do
# http://www.esvapi.org/v2/rest/passageQuery?key=IP&passage=Gen+1&include-headings=false

    query =
      %{ "key" => @esvKey,
        "passage" => Regex.replace(~r/\:/, vss, "."), # no colons!
        "include-headings" => "false"
      } |> URI.encode_query
    url = URI.encode("www.esvapi.org/v2/rest/passageQuery?#{query}")
    case  HTTPoison.get(url) do
      {:ok, resp} ->
        Logger.info "ESV URL: #{url}"
        resp.body
      {:error, _reason} ->
        "ESV text Failed badly"
    end
  end
end