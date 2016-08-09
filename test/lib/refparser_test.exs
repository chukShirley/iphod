ExUnit.start
defmodule RefParser do

  import Version.BookNames, only: [book_name: 1]
  use ExUnit.Case
  
  def tokenize(s) do
    Regex.split(~r/\d+|[a-z]+/, s |> String.downcase, include_captures: true)
    |> Enum.reduce([], fn(el, acc)-> 
        acc = if String.strip(el) |> String.length == 0, do: acc, else: acc ++ [String.strip el]
      end)
  end

  @spec book(String.t) :: {String.t, Enum.t}
  def book(s), do: book(tokenize(s), {"", []})
  def book([h|t], {"", []}), do: _book(t, {h,[]})

  def _book([], tup), do: tup

  def _book([h|t], {name, []}) do
    if Regex.match?(~r/\d+/, h) do
      _book([], {name, [h|t]})
    else 
      _book(t, {name <> " " <> h, []})
    end
  end

  @spec chapter_vss(Enum.t) :: {integer, integer, integer}
  def chapter_vss([chapter]), do: {String.to_integer(chapter), 1, 999}
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

  test  "sanity" do
    assert true, "insane if fails"
  end

  test "tokenize reference" do
    assert (["john", "3", ":", "16"] = tokenize("John 3:16"))
    assert (["john", "3", ":", "16"] = tokenize("John3:16"))
    assert (["1", "john", "1", ":", "12", "-", "20"]) = tokenize("1 john 1:12 - 20")
    assert (["1", "john", "1", ":", "12", "-", "20"]) = tokenize("1john1:12-20")
    assert (["1", "john", "1", ":", "12", "-", "2", ":", "10"]) = tokenize("1 john 1:12 - 2:10")
    assert (["1", "john", "1", ":", "12", "-", "15", ",", "2", ":", "10", "-", "15"]) = tokenize("1 john 1:12-15, 2:10-15")
  end

  test "all remaining vss in chapter" do
    assert ~w(john 3 : 16 - end) == tokenize("john 3:16-end")
    assert ~w(john 3 : 16 ff) == tokenize("john 3:16ff")
  end

  test "get book name" do
    assert({"john", ["3", ":", "16"]} = book("John 3:16") )
    assert({"1 john", ["1", ":", "12", "-", "20"]} = book("1 john 1:12 - 20") )
    assert({"1 john", ["1", ":", "12", "-", "2", ":", "10"]} = book("1 john 1:12 - 2:10") )
    assert({"1 john", ["1", ":", "12", "-", "15", ",", "2", ":", "10", "-", "15"]} = book("1 john 1:12-15, 2:10-15") )
    assert {"song of solomon", ["1", ":", "1", "-", "10"]} = book ("Song of Solomon 1:1-10")
  end

  test "best guess of book name" do
    assert "john" == book_name("jn")
  end

  test "get chapter and verses" do
    assert {3,16,16} == chapter_vss(["3", ":", "16"])
    assert {3,16,20} == chapter_vss(["3", ":", "16", "-", "20"])
  end

  test "get list of chapters and vss" do
    assert [{3, 16, 20}, {4, 2, 8}] == all_vss(~w(3 : 16 - 20 , 4 : 2 - 8))
    assert [{3, 16, 20}, {3, 24, 28}] == all_vss(~w(3 : 16 - 20 , 24 - 28))
    assert [{3, 16, 16}, {3, 24, 28}] == all_vss(~w(3 : 16 , 24 - 28))
    assert [{3, 16, 16}, {3, 24, 28}, {4, 1, 5}] == all_vss(~w(3 : 16 , 24 - 28 , 4 : 1 - 5))
  end

  test "get chapters & vss to end of chapter" do
    assert [{3, 16, 999}] == all_vss(~w(3 : 16 - end))
    assert [{3, 16, 999}] == all_vss(~w(3 : 16 ff))
    assert [{3, 1, 6}, {3, 16, 999}] == all_vss(~w(3 : 1 - 6 , 3 : 16 ff))
    assert [{3, 1, 6}, {3, 16, 999}] == all_vss(~w(3 : 1 - 6 , 16 ff))
  end

  test "get biblical reference" do
    assert {"john", [{3, 16, 16}]} == reference("john 3:16")
    assert {"john", [{3, 1, 999}]} == reference("John 3")
  end
end