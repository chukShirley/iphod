import IEx
defmodule LocalText do
  import Version.BookNames, only: [book_name: 1]

  def start_link, do: Agent.start_link fn -> build end, name: __MODULE__
  def identity(), do: Agent.get(__MODULE__, &(&1))

  def version(s), do: identity[s]

  def passage(ver, book), do: version(ver).book[book]

  def passage(ver, book, chapter) do
    passage(ver, book) |> Enum.at(chapter - 1)
  end

  def passage(ver, book, chapter, from, to) do
     passage(ver, book, chapter) |> Enum.slice((from-1)..(to-1))
  end

  def request(ver, ref) do
    request(ver, reference(ref), [])
  end

  def request(ver, {book, []}, list), do: {ver, book, list}
  def request(ver, {book, [{chap, first, last}|t]}, list) do
    request(ver, {book, t}, list ++ [passage(ver, book, chap, first, last)])
  end

  def tokenize(s) do
    Regex.split(~r/\d+|[a-z]+/, s |> String.downcase, include_captures: true)
    |> Enum.reduce([], fn(el, acc)-> 
        acc = if String.strip(el) |> String.length == 0, do: acc, else: acc ++ [String.strip el]
      end)
  end

  @spec book(String.t) :: {String.t, Enum.t}
  def book(s), do: book(tokenize(s), {"", []})
  def book([h|t], {"", []}), do: _book(t, {h,[]})

  def _book([], {name, list}), do: {book_name(name), list}

  def _book([h|t], {name, []}) do
    if Regex.match?(~r/\d+/, h) do
      _book([], {name, [h|t]})
    else 
      _book(t, {name <> " " <> h, []})
    end
  end

  @spec chapter_vss(Enum.t) :: {integer, integer, integer}
  def chapter_vss([chapter, ":", vs ]), do: {String.to_integer(chapter), String.to_integer(vs), String.to_integer(vs)}
  def chapter_vss([chapter, ":", first, "-", "end"]), do: chapter_vss([chapter, ":", first, "ff"])
  def chapter_vss([chapter, ":", first, "-", last]), do: {String.to_integer(chapter), String.to_integer(first), String.to_integer(last)}
  def chapter_vss([chapter, ":", first, "ff"]), do: {String.to_integer(chapter), String.to_integer(first), 999}

  @spec all_vss(Enum.t) :: Enum.t
  def all_vss(l), do: all_vss l |> Enum.chunk_by(&(&1 == ",")), []

  def all_vss([], list), do: list |> Enum.reverse
  def all_vss([[","]|t], list), do: all_vss(t, list)
  def all_vss([[first, "ff"] | t], list), do: all_vss([[first, "-", "999"] | t], list)
  def all_vss([[first, "-", "end"]|t], list), do: all_vss([[first, "-", "999"]|t], list)
  def all_vss([[first, "-", last]|t], list) do
    {chap, _, _} = list |> hd
    all_vss t, [{chap, String.to_integer(first), String.to_integer(last)}] ++ list
  end
  def all_vss([h|t], list) when is_list(h) do
    all_vss t, [chapter_vss(h)] ++ list
  end

  def reference(s) do
    {b, vss} = book(s)
    {b, all_vss(vss)}
  end

  def build do
    import Version.Web

    %{  "web" => Version.Web.web,
        "vulgate" => Version.Vulgate.vulgate
    }
  end
end