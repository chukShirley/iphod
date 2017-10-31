require IEx
defmodule GetBibleText do
  import RequestParser, only: [get_bible_query: 1]
# PARAMETERS
# 
# There are just two parameters available, both are self-explanatory, passage and version.
# 
# Yet you can also use v, ver, lang and translation in place of version and p, text, scrip and scripture in place of passage.
# 
# You can call a book, chapter or a single verse, or even a string of verses. When the Version is omitted the KJV is provided by default.
# 
# The following are all valid:
# 
# http://getbible.net/json?passage=Jn3:16
# http://getbible.net/json?p=James
# http://getbible.net/json?text=ps119
# http://getbible.net/json?scrip=Acts 3:17-4;2:1
# http://getbible.net/json?scripture=Psa 119:4-16;23:1-6&v=amp
# http://getbible.net/json?passage=Acts 15:1-5, 10, 15&version=aov

  def request(ver, vss, _fnotes \\ "") do
    url = "http://getbible.net/json?p=#{get_bible_query(vss)}&v=#{ver}"
    case HTTPoison.get(url, [{"Accept", "application/jsonrequest"}], [follow_redirect: true]) do
      {:ok, resp} ->
        Regex.replace(~r/^\(|\)\;$/, resp.body, "")
        |> Poison.decode!
        |> body_to_string(vss)
      {:error, _reason} ->
        "GetBible text Failed Badly"
    end
  end

  def body_to_string([], text), do: text
  
  def body_to_string([h|t], text) do
    body_to_string t, text <> "#{verses( h["chapter"] |> Map.to_list, "")}"
  end

  def body_to_string(map, vss) do
    body_to_string map["book"], "<h2>#{vss}</h2>"
  end

  def verses([], text), do: text

  def verses([{vs, map}|t], text) do
    verses t, text <> verse_num(vs) <> verse_text(map["verse"])
  end

  def verse_num(n), do: "<br /><span class='vs_num'>#{n}</span> "

  def verse_text(s), do: "<span class='vs_text'>#{s}</span>"

  def passages_to_string([]), do: "Not Available"
  def passages_to_string(passages) do
    passages
      |> Enum.reduce( "", fn(passage, {text, _fnotes}) -> 
          passage_text = if passage["text"] |> String.length == 0, do: "Not Available", else: passage["text"]
          text = text <> passage["display"] <> "\n" <> passage_text
          text
        end) 
  end


end