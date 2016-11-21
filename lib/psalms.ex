require IEx
defmodule Psalms do
  import Coverdale
  import BCPPsalms

  def start_link do
    Agent.start_link fn -> build end, name: __MODULE__
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def psalm({119, v1, v2}, "Coverdale"), do: psalm(119, v1, v2, "Coverdale")
  def psalm({119, v1, v2}, "BCP"), do: psalm(119, v1, v2, "BCP")
  def psalm({119, v1, v2}, "ESV"), do: EsvText.request("Ps 119.#{v1}-#{v2}")
  def psalm({119, v1, v2}, ver), do: BibleComText.request(ver, "Ps 119.#{v1}-#{v2}")

  def psalm(n, ver ) when n |> is_bitstring, do: psalm(String.to_integer(n), ver)

  def psalm(n, "Coverdale"), do: identity.coverdale[n]
  def psalm(n, "COVERDALE"), do: identity.coverdale[n]
  def psalm(n, "BCP"), do: identity.bcp[n]
  def psalm(n, "ESV"), do: EsvText.request("Ps #{n}")
  def psalm(n, ver), do: BibleComText.request(ver, "Ps #{n}")

  def psalm_as_html([n], ver), do: psalm_as_html([n, 1, 999], ver)
  def psalm_as_html([n, v1, v2], "Coverdale") do
    psalm(n, v1, v2, "Coverdale") |> _to_html("Coverdale")
  end
  def psalm_as_html([n, v1, v2], "BCP") do
    psalm(n, v1, v2, "BCP") |> _to_html("BCP")
  end

  def psalm(n,v1,v2, "COVERDALE"), do: psalm(n,v1,v2, "Coverdale")
  def psalm(n,v1,v2, "Coverdale") do
    identity.coverdale[n] |> Map.take(list_of_vss(v1, v2))
  end
  def psalm(n,v1,v2, "BCP") do
    identity.bcp[n] |> Map.take(list_of_vss(v1, v2))
  end
  def psalm(n,v1,v2, "ESV"), do: EsvText.request("Ps #{n}.#{v1}-#{v2}")

  def list_of_vss(v1, v2) do
    v1..v2
    |> Enum.to_list
    |> List.flatten(["name", "title", "version"])
  end
  def morning(n), do: identity.day[n].mp
  def evening(n), do: identity.day[n].ep

  def morning_psalms(n, ver \\ "Coverdale"), do: morning(n) |> Enum.map(&(psalm &1, ver))
  def evening_psalms(n, ver \\ "Coverdale"), do: evening(n) |> Enum.map(&(psalm &1, ver))

  def to_html(s, ver) when s |> is_bitstring do
    s |> String.split([" ", ".", "-", ":"]) |> List.to_tuple |> _to_html(ver)
  end
  def _to_html({_, ps}, ver), do: ps |> String.to_integer |> _to_html(ver)
  def _to_html({_, ps, v1, v2}, ver) do
    psalm(String.to_integer(ps), String.to_integer(v1), String.to_integer(v2), ver )
    |> _to_html(ver)
  end
  def _to_html(n, ver) when n |> is_integer, do: _to_html(psalm(n, ver), ver)

  def _to_html(ps, "ESV"), do: ps # ESV comes ready to go
  def _to_html(ps, "BCP"), do: _to_local_html(ps)
  def _to_html(ps, "Coverdale"), do: _to_local_html(ps)
  def _to_html(ps, "COVERDALE"), do: _to_local_html(ps)
  def _to_html(ps, ver), do: ps # BibleComText comes ready to go

  def _to_local_html(ps) do
    s = ~s(<h3>#{ps["name"]} <span class="ps_title">#{ps["title"]}</span></h3></br>)
    ps 
      |> Enum.to_list
      |> Enum.sort
      |> Enum.reduce(s, fn(el, acc)->
          acc <> vs_to_html(el) end)
  end

  def vs_to_html({key, val}) when key |> is_integer do
    ~s( <p class="ps_first">
          <sup class="ps_vs_num">#{key}</sup>
          #{val.first}</p>
        <p class="ps_second">#{val.second}</p>
    ) 
  end
  def vs_to_html(_), do: ""

  def build do
    %{ day: 
        %{  1 => %{ mp: [1,2,3,4,5], ep: [6,7,8] },
            2 => %{ mp: [9,10,11], ep: [12,13,14] },
            3 => %{ mp: [15,16,17], ep: [18] },
            4 => %{ mp: [19,20,21], ep: [22,23] },
            5 => %{ mp: [24,25,26], ep: [27,28,29] },
            6 => %{ mp: [30,31], ep: [32,33,34] },
            7 => %{ mp: [35,36], ep: [37] },
            8 => %{ mp: [38,39,40], ep: [41,42,43] },
            9 => %{ mp: [44,45,46], ep: [47,48,49] },
            10 => %{ mp: [50,51,52], ep: [53,54,55] },
            11 => %{ mp: [56,57,58], ep: [59,60,61] },
            12 => %{ mp: [62,63,64], ep: [65,66,67] },
            13 => %{ mp: [68], ep: [69,70] },
            14 => %{ mp: [71,72], ep: [73,74] },
            15 => %{ mp: [75,76,77], ep: [78] },
            16 => %{ mp: [79,80,81], ep: [82,83,84,85] },
            17 => %{ mp: [86,87,88], ep: [89] },
            18 => %{ mp: [90,91,92], ep: [93,94] },
            19 => %{ mp: [95,96,97], ep: [98,99,100,101] },
            20 => %{ mp: [102,103], ep: [104] },
            21 => %{ mp: [105], ep: [106] },
            22 => %{ mp: [107], ep: [108, 109] },
            23 => %{ mp: [110,111,112,113], ep: [114,115] },
            24 => %{ mp: [116,117,118], ep: [{119,1,32}] },
            25 => %{ mp: [{119,33,72}], ep: [{119, 73,104}] },
            26 => %{ mp: [{119,105,144}], ep: [{119,145,176}] },
            27 => %{ mp: [120,121,122,123,124,125], ep: [126,127,128,129,130,131] },
            28 => %{ mp: [132,133,134,135], ep: [136,137,138] },
            29 => %{ mp: [139,140], ep: [141,143] },
            30 => %{ mp: [144,145,146], ep: [147,148,149,150] },
            31 => %{ mp: [120,121,122,123,124,125,126,127], ep: [128,129,130,130,132,133,134] }
        },
      coverdale: Coverdale.coverdale,
      bcp:    BCPPsalms.bcp
    }
  end
end