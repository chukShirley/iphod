require IEx
require Logger
defmodule EsvText do
  import RequestParser, only: [esv_query: 1]
  @esvKey "10b28dac7c57fd96"

  def request(vss, fnotes \\ [include_footnotes: "true"]) do
   case  HTTPoison.get(esv_url(vss, fnotes)) do
      {:ok, resp} ->
        if Regex.match?(~r/^ERROR/, resp.body) do
          LocalText.request("web", vss)
        else
          resp.body
        end
      {:error, _reason} ->
        "ESV text Failed badly"
    end
  end

  def request_raw(keywords) do
   case  HTTPoison.get(esv_url_raw(keywords)) do
      {:ok, resp} ->
        if Regex.match?(~r/^ERROR/, resp.body) do
          IO.puts "!!!!! #{inspect keywords[:passage] }\n\t#{inspect resp.body}"
          passage = keywords[:passage] |> String.replace(".", ":")
          LocalText.request("web", passage)
        else
          resp.body
        end
      {:error, _reason} ->
        "ESV text Failed badly"
    end
    
  end

  def esv_url_raw(keywords) do
# http://www.esvapi.org/v2/rest/passageQuery?key=IP&passage=Gen+1&include-headings=false
    # footnotes = if fnotes == "fnotes", do: "true", else: "false"
    query = keywords
      |> Keyword.keys 
      |> Enum.reduce(%{"key" => @esvKey}, fn(k, acc) -> 
        # atoms can't have "-" and ESV APIuses them
        # so change atoms with "_" to strings with "-"
        key = k |> Atom.to_string |> String.replace("_", "-")
        acc |> Map.put(key, keywords[k]) 
      end)
      |> URI.encode_query
    URI.encode("www.esvapi.org/v2/rest/passageQuery?#{query}")     
  end


  def esv_url(vss, fnotes \\ "fnotes") do
# http://www.esvapi.org/v2/rest/passageQuery?key=IP&passage=Gen+1&include-headings=false
    footnotes = if fnotes == "fnotes", do: "true", else: "false"
    query =
      %{  "key" => @esvKey,
          "passage" => esv_query(vss),
          "include-headings" => "false",
          "include-footnotes" => footnotes
      } |> URI.encode_query
    URI.encode("www.esvapi.org/v2/rest/passageQuery?#{query}")     
  end
end