defmodule RequestParser do
  import BookNames, only: [book_name: 1, web_name: 1]
  
  def tokenize(s) do
    Regex.split(~r/\d+|[a-z]+/, s |> String.downcase, include_captures: true)
    |> Enum.reduce([], fn(el, acc)-> 
        if String.trim(el) |> String.length == 0, do: acc, else: acc ++ [String.trim el]
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
  def chapter_vss([chapter]), do: ref_to_tup chapter, 1, 999
  def chapter_vss([first, "-", last]), do: ref_to_tup first, last
  def chapter_vss([chapter, first, "-", last]), do: ref_to_tup chapter, first, last
  def chapter_vss([chapter, ":", vs ]), do: ref_to_tup chapter, vs, vs
  def chapter_vss([chapter, ":", first, "-", "end"]), do: ref_to_tup chapter, first, 999
  def chapter_vss([chapter, ":", first, "-", last]), do: ref_to_tup chapter, first, last
  def chapter_vss([chapter, ":", first, "ff"]), do: ref_to_tup chapter, first, 999
# case of first vs no. w/ trailing letter and other vs nos.
  def chapter_vss([chapter, ":", first, _letter, "-", last]), do: ref_to_tup chapter, first, last
# case of first vs no. w/ trailing letter and no other vs nos.
  def chapter_vss([chapter, ":", first, _letter]), do: ref_to_tup chapter, first, first
# case of last vs no. w/ trailing letters
  def chapter_vss([chapter, ":", first, "-", last, _letters]), do: ref_to_tup chapter, first, last
# n.b. in the case of returning a list, the order MUST be refereced
  def chapter_vss([chap1, ":", first, "-", chap2, ":", last]) do 
    [ ref_to_tup( chap2, 1, last),
      ref_to_tup( chap1, first, 999)
    ]
  end

  def ref_to_tup(v1, "end"), do: {nil, String.to_integer(v1), 999}
  def ref_to_tup(v1, v2), do: {nil, String.to_integer(v1), String.to_integer(v2)}
  def ref_to_tup(chap, 1, 999), do: {String.to_integer(chap), 1, 999}
  def ref_to_tup(chap, 1, v2), do: {String.to_integer(chap), 1, String.to_integer(v2)}
  def ref_to_tup(chap, v1, 999), do: {String.to_integer(chap), String.to_integer(v1), 999}
  def ref_to_tup(chap, v1, v2), do: {String.to_integer(chap), String.to_integer(v1), String.to_integer(v2)}

  @spec all_vss(Enum.t) :: Enum.t
  def all_vss(l) do 
    all_vss l |> Enum.chunk_by(&(&1 == ",")), []
  end

  def all_vss([], list), do: list |> List.flatten |> Enum.reverse
  def all_vss([[first, "-", "end"]|t], []) do
    all_vss t, [{nil, String.to_integer(first), 999}]
  end
  def all_vss([[first, "-", last]|t], []) do
    all_vss t, [{nil, String.to_integer(first), String.to_integer(last)}]
  end

  def all_vss([[","]|t], list), do: all_vss(t, list)
  def all_vss([[first, "ff"] | t], list), do: all_vss([[first, "-", "999"] | t], list)
  def all_vss([[first, "-", "end"]|t], list), do: all_vss([[first, "-", "999"]|t], list)
  def all_vss([[first, "-", last]|t], list) do
    {chap, _, _} = list |> hd
    all_vss t, [{chap, String.to_integer(first), String.to_integer(last)}] ++ list
  end
  def all_vss([h|t], list) when is_list(h) do
    # first make sure the book ref is not part of vss ref
    this_head = if h |> hd |> String.match?(~r/[a-zA-Z]+/), do: h |> tl, else: h
    all_vss t, [chapter_vss(this_head)] ++ list
  end

  def reference(s) do
    {b, vss} = book(s)
    {b, all_vss(vss)}
  end

  def local_query(s) do
    {book, vs_list} = reference(s)
    {web_name(book), vs_list}
  end

  def esv_query(s) do
    {book, vs_list} = reference(s)
    vs_list 
      |> Enum.reduce("#{book}", fn({chap, first, last}, acc)->
          if chap, do: acc <> " #{chap}.#{first}-#{last}", else: acc <> " #{first}-#{last}"
        end)
  end

  def get_bible_query(s), do: common_query s

  def bible_com_query(s), do: common_query s

  defp common_query(s) do
    {book, vs_list} = reference(s)
    book = Regex.replace ~r/\s/, book, "+"
    vs_list 
      |> Enum.reduce("#{book}", fn({chap, first, last}, acc)->
          acc <> "+#{chap}:#{first}-#{last}"
        end)
  end
end