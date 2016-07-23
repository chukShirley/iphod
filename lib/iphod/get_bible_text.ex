require IEx
defmodule GetBibleText do

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

  def request(ver, vss, fnotes \\ "") do
    vss = Regex.replace(~r/\s/, vss, "+")
    url = "http://getbible.net/json?p=#{vss}&v=#{ver}"
    case HTTPoison.get(url, [{"Accept", "application/jsonrequest"}], [follow_redirect: true]) do
      {:ok, resp} ->
        Regex.replace(~r/^\(|\)\;$/, resp.body, "")
        |> Poison.decode!
        IEx.pry
        ""
      {:error, _reason} ->
        IEx.pry
        "GetBible text Failed Badly"
    end
  end

  def passages_to_string([]), do: "Not Available"


end