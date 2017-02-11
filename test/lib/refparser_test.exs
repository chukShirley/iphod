ExUnit.start
defmodule RefParser do
  import BookNames, only: [book_name: 1]
  import RequestParser
  use ExUnit.Case
  

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
    assert tokenize("philemon 1-3") == ["philemon", "1", "-", "3"]
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
    assert book("philemon 1-3") == {"philemon", ["1", "-", "3"]}
  end

  test "best guess of book name" do
    assert "john" == book_name("jn")
  end

  test "get chapter and verses" do
    assert {3,16,16} == chapter_vss(["3", ":", "16"])
    assert {3,16,20} == chapter_vss(["3", ":", "16", "-", "20"])
    assert chapter_vss(["119", "33", "-", "72"]) == {119, 33, 72}
    assert chapter_vss(["1", "-", "3"]) == {nil, 1, 3}
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

  test "get vss where book has one chapter (e.g. philemon)" do
    assert all_vss(["1", "-", "3"]) == [{nil, 1, 3}]
  end

  test "get biblical reference" do
    assert {"john", [{3, 16, 16}]} == reference("john 3:16")
    assert {"john", [{3, 1, 999}]} == reference("John 3")
    assert {"psalms", [{119, 33, 72}]} == reference("Psalm 119 33-72")
  end

  test "references with book mentioned multiple times" do
    ref = "Hab 3:1,Hab 3:2-15,Hab 3:16-19"
    assert reference(ref) == {"habakkuk", [{3,1,1}, {3,2,15}, {3,16,19}]}
  end

  test "problematic readings" do
    assert reference("Isaiah 61:10-end, 62:1-5") == {"isaiah", [{61,10,999}, {62,1,5}]}
    assert reference("Jer 3:19-4:4") == {"jeremiah", [{3,19,999},{4,1,4}]}
    assert reference("2 Kings 5:1-15ab") == {"2 kings", [{5,1,15}]}
    assert reference("Lev 19:1-2, 19:9-18") == {"leviticus", [{19,1,2},{19,9,18}]}
    assert reference("1 Cor 12:27-13:13") == {"1 corinthians", [{12,27,999},{13,1,13}]}
    assert reference("Gen 2:4-9, 2:15-17, 2:25-end, 3:1-7") == {"genesis", [{2,4,9},{2,15,17},{2,25,999},{3,1,7}]}
    assert reference("Genesis 1, 2:1-2") == {"genesis", [{1,1,999},{2,1,2}]}
    assert reference("Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13") == {"genesis", [{7,1,5},{7,11,18},{8,8,18},{9,8,13}]}
    assert reference("Acts 3:12a, 3:13-15, 3:17-26") == {"acts", [{3,12,12},{3,13,15},{3,17,26}]}
    assert reference("Acts 13:14b-16, 13:26-39") == {"acts", [{13,14,16},{13,26,39}]}
    assert reference("Rev 21:1-4, 21:22-end, 22:1-5") == {"revelation", [{21,1,4},{21,22,999},{22,1,5}]}
    assert reference("1 Kings 8:22-30, 41-43") == {"1 kings", [{8,22,30},{8,41,43}]}
    assert reference("Gen 25:7-11, 19-end") == {"genesis", [{25,7,11},{25,19,999}]}
    assert reference("Exod 33, 34") == {"exodus", [{33,1,999},{34,1,999}]}
    assert reference("Lev 19:1-18, 30- end") == {"leviticus", [{19,1,18},{19,30,999}]}
    assert reference("Num 9:15-end, 10:19-end") == {"numbers", [{9,15,999},{10,19,999}]}
    assert reference("Num 13:1-2, 17-end") == {"numbers", [{13,1,2},{13,17,999}]}
    assert reference("1 Thess 2:17-end, 3") == {"1 thessalonians", [{2,17,999},{3,1,999}]}
    assert reference("Philemon 1-3") == {"philemon", [{nil,1,3}]}
  end

  test "ESV queries" do
    assert esv_query("john 3:16") == "john 3.16-16"
    assert esv_query("John 3") == "john 3.1-999"
    assert esv_query("Isaiah 61:10-end, 62:1-5") == "isaiah 61.10-999 62.1-5"
    assert esv_query("Acts 3:12a, 3:13-15, 3:17-26") == "acts 3.12-12 3.13-15 3.17-26"
    assert esv_query("Gen 2:4-9, 2:15-17, 2:25-end, 3:1-7") == "genesis 2.4-9 2.15-17 2.25-999 3.1-7"
    assert esv_query("1 Thess 2:17-end, 3") == "1 thessalonians 2.17-999 3.1-999"
    assert esv_query("Philemon 1-3") == "philemon 1-3"
  end
end