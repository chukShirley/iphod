require IEx
require Logger
defmodule BibleText do
  @bibleKey "P7jpdltnMhHJYUlx8TZEiwvJHDvSrZ96UCV522kT"
#   GET /v2/passages.js?q[]=Isa 14.28-end,15.1-9&version=ESV HTTP/1.1
#   Host: bibles.org
#   Authorization: Basic UDdqcGRsdG5NaEhKWVVseDhUWkVpd3ZKSER2U3JaOTZVQ1Y1MjJrVDp0aGlzaXNpZ25vcmVk
#   Cache-Control: no-cache
#   Postman-Token: d201547d-dcff-7252-f492-f449e4377677

#    hackney = [basic_auth: {"user", "pass"}]
#    assert_response HTTPoison.get("http://localhost:8080/basic-auth/user/pass", [], [ hackney: hackney ])

  def request(ver, vss, fnotes \\ "fnotes") do
    # https://bibles.org/v2/passages.js?q[]=Isa 14.28-end,15.1-9&version=eng-ESV
    vss = Regex.replace(~r/\s/, vss, "+")
    auth = [basic_auth: {@bibleKey, "makesnodifference"}]
    footnotes = if fnotes == "fnotes", do: "true", else: "false"
    url = "https://bibles.org/v2/passages.js?q[]=#{vss}&include_marginalia=#{footnotes}&version=#{ver}"
    IO.puts "URL: #{url}"
    case  HTTPoison.get(url, [{"Accept", "application/jsonrequest"}], [hackney: auth, follow_redirect: true]) do
      {:ok, resp} ->
        IEx.pry
        map = resp.body 
        |> Poison.decode!
        # map["response"]["search"]["result"]["passages"] # always a list
        # |> Enum.reduce "", fn(passage, acc) -> end) 
        # and the above fn() should do what?
      {:error, _reason} ->
        "ESV text Failed badly"
    end
  end
end