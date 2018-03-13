require IEx
defmodule BibleVersions do
  @url "https://bibles.org/v2/versions.js"
  @username "P7jpdltnMhHJYUlx8TZEiwvJHDvSrZ96UCV522kT" 
  @password "couldbeanything"

  def start_link do
    Agent.start_link fn -> build() end, name: __MODULE__
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def source(ver), do: identity()[ver]["source"]
  def id(abbreviation), do: identity()[abbreviation]["id"]
  def list_all() do
    identity()
      |> Map.to_list
      |> Enum.map(fn({id, map})-> {id, map["abbreviation"], map["name"], map["lang_name_eng"]} end)
  end

  def build do
    auth = [basic_auth: {@username, @password}]
    {_ok, resp} = try do
      HTTPoison.get(@url, [{"Accept", "application/jsonrequest"}], [hackney: auth, follow_redirect: true])
    rescue
      _e in RuntimeError -> 
        {:error, %{status_code: 500}} # call it `internal server error`
    end
    status_code = if resp |> Map.has_key?(:status_code), do: resp.status_code, else: nil
    map = case status_code do
      200 ->
        body = resp.body |> Poison.decode!
        body["response"]["versions"]
          |> Enum.reduce(%{}, fn(ver, acc)-> 
            new_ver = ver |> Map.put("source", "bibles.org")
            acc |> Map.put_new(ver["abbreviation"], new_ver) end)
      _ ->
        IO.puts ">>>>> Bibles.org failed with status code: #{inspect status_code}"
        %{}
    end
    map2 = 
      get_bible_translations()
      |> Enum.reduce(map, fn(ver, acc)->
        acc |> Map.put_new(ver["abbreviation"], ver)
      end)
    local_bible_translations()
      |> Enum.reduce(map2, fn(ver, acc)->
        acc |> Map.put_new(ver["abbreviation"], ver)
      end)
  end

###
  defp get_bible_translations do
    # {lang_name, name, abbreciation}
    [ %{"lang_name_eng" =>"Afrikaans", "name" => "Ou Vertaling", "abbreviation" => "aov", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Albanian", "name" => "Albanian", "abbreviation" => "albanian", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Amharic", "name" => "Haile Selassie Amharic Bible", "abbreviation" => "hsab", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Arabic", "name" => "Smith and Van Dyke", "abbreviation" => "arabicsv", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Bulgarian", "name" => "Bulgarian Bible (1940)", "abbreviation" => "bulgarian1940", "source" => "getbible.net"},
      # %{"lang_name_eng" =>"Chinese", "name" => "NCV Traditional", "abbreviation" => "cnt", "source" => "getbible.net"},
      # %{"lang_name_eng" =>"Chinese", "name" => "Union Simplified", "abbreviation" => "cus", "source" => "getbible.net"},
      # %{"lang_name_eng" =>"Chinese", "name" => "NCV Simplified", "abbreviation" => "cns", "source" => "getbible.net"},
      # %{"lang_name_eng" =>"Chinese", "name" => "Union Traditional", "abbreviation" => "cut", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Croatian", "name" => "Croatian", "abbreviation" => "croatia", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Danish", "name" => "Danish", "abbreviation" => "danish", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Dutch", "name" => "Dutch Staten Vertaling", "abbreviation" => "statenvertaling", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "King James Version", "abbreviation" => "kjv", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "KJV Easy Read", "abbreviation" => "akjv", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "American Standard Version", "abbreviation" => "asv", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "Amplified Version", "abbreviation" => "amp", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "Basic English Bible", "abbreviation" => "basicenglish", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "Darby", "abbreviation" => "darby", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "New American Standard", "abbreviation" => "nasb", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "Young's Literal Translation", "abbreviation" => "ylt", "source" => "getbible.net"},
      %{"lang_name_eng" =>"English", "name" => "English Standard Version", "abbreviation" => "ESV", "source" => "esvapi.org"},
      %{"lang_name_eng" =>"Esperanto", "name" => "Esperanto", "abbreviation" => "esperanto", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Estonian", "name" => "Estonian", "abbreviation" => "estonian", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Finnish", "name" => "Finnish Bible (1776)", "abbreviation" => "finnish1776", "source" => "getbible.net"},
      %{"lang_name_eng" =>"French", "name" => "Martin (1744)", "abbreviation" => "martin", "source" => "getbible.net"},
      %{"lang_name_eng" =>"German", "name" => "Luther (1912)", "abbreviation" => "luther1912", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Greek", "name" => "Greek Modern", "abbreviation" => "moderngreek", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Greek", "name" => "Textus Receptus", "abbreviation" => "text", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Hebrew", "name" => "Aleppo Codex", "abbreviation" => "aleppo", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Hungarian", "name" => "Hungarian Karoli", "abbreviation" => "karoli", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Italian", "name" => "Giovanni Diodati Bible (1649)", "abbreviation" => "giovanni", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Korean", "name" => "Korean", "abbreviation" => "korean", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Norwegian", "name" => "Bibelselskap (1930)", "abbreviation" => "bibelselskap", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Portuguese", "name" => "Almeida Atualizada", "abbreviation" => "almeida", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Russian", "name" => "Synodal Translation (1876)", "abbreviation" => "synodal", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Spanish", "name" => "Reina Valera (1909)", "abbreviation" => "valera", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Swahili", "name" => "Swahili", "abbreviation" => "swahili", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Swedish", "name" => "Swedish (1917)", "abbreviation" => "swedish", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Turkish", "name" => "Turkish", "abbreviation" => "turkish", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Vietnamese", "name" => "Vietnamese (1934)", "abbreviation" => "vietnamese", "source" => "getbible.net"},
      %{"lang_name_eng" =>"Xhosa", "name" => "Xhosa", "abbreviation" => "xhosa", "source" => "getbible.net"}
    ]
  end

  defp local_bible_translations do
    [ %{"lang_name_eng" =>"English", "name" => "World English Bible", "abbreviation" => "web", "source" => "local"},
      %{"lang_name_eng" =>"Latin", "name" => "Latin: Vulgata Clementina", "abbreviation" => "vulgate", "source" => "local"},
      %{"lang_name_eng" =>"Chinese", "name" => "Chinese Union Simplified", "abbreviation" => "cu89s", "source" => "local"},
      %{"lang_name_eng" =>"Chinese", "name" => "Chinese Union Traditional", "abbreviation" => "cu89t", "source" => "local"},
      %{"lang_name_eng" =>"English", "name" => "Coverdale", "abbreviation" => "Coverdale", "source" => "Coverdale"},
      %{"lang_name_eng" =>"English", "name" => "BCP", "abbreviation" => "BCP", "source" => "BCP"},
    ]
  end

end