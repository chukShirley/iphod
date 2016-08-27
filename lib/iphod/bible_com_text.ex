require IEx
require Logger
defmodule BibleComText do
  @bibleKey "P7jpdltnMhHJYUlx8TZEiwvJHDvSrZ96UCV522kT"
  import RequestParser, only: [bible_com_query: 1]
#   GET /v2/passages.js?q[]=Isa 14.28-end,15.1-9&version=ESV HTTP/1.1
#   Host: bibles.org
#   Authorization: Basic UDdqcGRsdG5NaEhKWVVseDhUWkVpd3ZKSER2U3JaOTZVQ1Y1MjJrVDp0aGlzaXNpZ25vcmVk
#   Cache-Control: no-cache
#   Postman-Token: d201547d-dcff-7252-f492-f449e4377677

#    hackney = [basic_auth: {"user", "pass"}]
#    assert_response HTTPoison.get("http://localhost:8080/basic-auth/user/pass", [], [ hackney: hackney ])

  def request(ver, vss, fnotes \\ "fnotes") do
    # https://bibles.org/v2/passages.js?q[]=Isa 14.28-end,15.1-9&version=eng-ESV
    # https://bibles.org/v2/passages.js?q[]=Isa+14.28-end&15.1-9&include_marginalia=true&footnotes=true&version=web
    id = BibleVersions.id(ver)
    auth = [basic_auth: {@bibleKey, "makesnodifference"}]
    footnotes = if fnotes == "fnotes", do: "true", else: "false"
    url = "https://bibles.org/v2/passages.js?q[]=#{bible_com_query(vss)}&include_marginalia=#{footnotes}&version=#{id}"
    case  HTTPoison.get(url, [{"Accept", "application/jsonrequest"}], [hackney: auth, follow_redirect: true]) do
      {:ok, resp} ->
        resp.body 
        |> Poison.decode!
        |> body_to_string
      {:error, _reason} ->
        "BibleCom text Failed badly"
    end
  end

  def body_to_string(map) do
    map["response"]["search"]["result"]["passages"] |> passages_to_string
  end

  def passages_to_string([]), do: "Not Available"
  def passages_to_string(passages) do
    {text, fnotes} = passages
      |> Enum.reduce( {"",""}, fn(passage, {text, fnotes}) -> 
          passage_text = if passage["text"] |> String.length == 0, do: "Not Available", else: passage["text"]
          text = text <> passage["display"] <> "\n" <> passage_text
          fnotes = if passage["footnotes"], do: fnotes <> footnotes_to_string(passage["footnotes"]), else: fnotes
          {text, fnotes}
        end) 
    text <> "<b>Footnotes</b></br>" <> fnotes
  end

  def footnotes_to_string(footnotes) do
    # "footnotes": [
    #   {
    #     "marker": "+",
    #     "content": "<span verse_id=\"Acts.26.19\" id=\"Acts.26.19!f.1\" class=\"note f\"><span class=\"fr\">26.19 </span><span class=\"ft\">I mer tzij xu bij are iri: wach i xwil pin wach.</span></span>",
    #     "note_id": "Acts.26.19!f.1",
    #     "verse_id": "acr-ACRNT:Acts.26.19"
    #   }
    # ],

    footnotes
    |> Enum.reduce( "", &(&2 = "#{&2}<b>#{&1["marker"]}</b> #{&1["content"]}\n"))
  end
end