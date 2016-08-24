require IEx
require Ecto.Query
alias Iphod.Repo
alias Iphod.Bible

defmodule LocalText do
  import BookNames, only: [book_name: 1]
  import Ecto.Query, only: [from: 2]

  def passage(ver, book, chapter) do
    query = from Bible, where: [trans: ^ver, book: ^book, chapter: ^chapter]
    resp = Repo.one(query)
    resp.vss
  end

  def passage(ver, book, chapter, from, to) do
    {vss, _} =passage(ver, book, chapter) 
      |> Enum.slice(from..to)
      |> Enum.reduce({[], from}, fn(vs, {acc, i})->
        new_vss = "<sup class='vs_number'>#{i}</sup> #{vs}"
        new_i = i + 1
        {[new_vss | acc], new_i}
      end)
    vss |> Enum.reverse
  end

  def request(ver, ref) do
    {ver, book, lists} = request(ver, reference(ref), [])
    lists_to_html(lists, "<h3>#{ref |> String.capitalize}</h3>")
  end

  def request(ver, {book, []}, list), do: {ver, book, list}
  def request(ver, {book, [{chap, first, last}|t]}, list) do
    request(ver, {book, t}, list ++ [passage(ver, book, chap, first, last)])
  end

# if it's not a list, just send the string back
  def list_to_html(s), do: s

  def lists_to_html([], html), do: html

  def lists_to_html([h|t], html) do
    IEx.pry
    new_html = html <> "<p>" <> Enum.join(h, "</br>") <> "</p>"
    lists_to_html t, new_html
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
  def chapter_vss([chapter]), do: {String.to_integer(chapter), 1, 999}
  def chapter_vss([chapter, first, "-", last]), do: {String.to_integer(chapter), String.to_integer(first), String.to_integer(last)}
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

end