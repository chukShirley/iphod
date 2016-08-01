ExUnit.start
defmodule RefParser do
  @book_names %{
"genesis"=>"genesis", "gen"=>"genesis", "ge"=>"genesis", "gn"=>"genesis",
"exodus"=>"exodus",  "exo"=>"exodus", "ex"=>"exodus", "exod"=>"exodus",
"leviticus"=>"leviticus", "lev"=>"leviticus", "le"=>"leviticus", "lv"=>"leviticus",
"numbers"=>"numbers", "num"=>"numbers", "nu"=>"numbers", "nm"=>"numbers", "nb"=>"numbers",
"deuteronomy"=>"deuteronomy", "deut"=>"deuteronomy", "dt"=>"deuteronomy",
"joshua"=>"joshua",  "josh"=>"joshua", "jos"=>"joshua", "jsh"=>"joshua",
"judges"=>"judges",  "judg"=>"judges", "jdg"=>"judges", "jg"=>"judges", "jdgs"=>"judges",
"ruth"=>"ruth",  "rth"=>"ruth", "ru"=>"ruth",
"1 samuel"=>"1 samuel",  "1 sam"=>"1 samuel", "1 sa"=>"1 samuel", "1samuel"=>"1 samuel", "1s"=>"1 samuel", "i sa"=>"1 samuel", "1 sm"=>"1 samuel", "1sa"=>"1 samuel", "i sam"=>"1 samuel", "1sam"=>"1 samuel", "i samuel"=>"1 samuel", "1st samuel"=>"1 samuel", "first samuel"=>"1 samuel",
"2 samuel"=>"2 samuel",  "2 sam"=>"2 samuel", "2 sa"=>"2 samuel", "2s"=>"2 samuel", "ii sa"=>"2 samuel", "2 sm"=>"2 samuel", "2sa"=>"2 samuel", "ii sam"=>"2 samuel", "2sam"=>"2 samuel", "ii samuel"=>"2 samuel", "2samuel"=>"2 samuel", "2nd samuel"=>"2 samuel", "second samuel"=>"2 samuel",
"1 kings"=>"1 kings", "1 kgs"=>"1 kings", "1 ki"=>"1 kings", "1k"=>"1 kings", "i kgs"=>"1 kings", "1kgs"=>"1 kings", "i ki"=>"1 kings", "1ki"=>"1 kings", "i kings"=>"1 kings", "1kings"=>"1 kings", "1st kgs"=>"1 kings", "1st kings"=>"1 kings", "first kings"=>"1 kings", "first kgs"=>"1 kings", "1kin"=>"1 kings",
"2 kings"=>"2 kings", "2 kgs"=>"2 kings", "2 ki"=>"2 kings", "2k"=>"2 kings", "ii kgs"=>"2 kings", "2kgs"=>"2 kings", "ii ki"=>"2 kings", "2ki"=>"2 kings", "ii kings"=>"2 kings", "2kings"=>"2 kings", "2nd kgs"=>"2 kings", "2nd kings"=>"2 kings", "second kings"=>"2 kings", "second kgs"=>"2 kings", "2kin"=>"2 kings",
"1 chronicles"=>"1 chronicles",  "1 chron"=>"1 chronicles", "1 ch"=>"1 chronicles", "i ch"=>"1 chronicles", "1ch"=>"1 chronicles", "1 chr"=>"1 chronicles", "i chr"=>"1 chronicles", "1chr"=>"1 chronicles", "i chron"=>"1 chronicles", "1chron"=>"1 chronicles", "i chronicles"=>"1 chronicles", "1chronicles"=>"1 chronicles", "1st chronicles"=>"1 chronicles", "first chronicles"=>"1 chronicles",
"2 chronicles"=>"2 chronicles",  "2 chron"=>"2 chronicles", "2 ch"=>"2 chronicles", "ii ch"=>"2 chronicles", "2ch"=>"2 chronicles", "ii chr"=>"2 chronicles", "2chr"=>"2 chronicles", "ii chron"=>"2 chronicles", "2chron"=>"2 chronicles", "ii chronicles"=>"2 chronicles", "2chronicles"=>"2 chronicles", "2nd chronicles"=>"2 chronicles", "second chronicles"=>"2 chronicles",
"ezra"=>"ezra",  "ezra"=>"ezra", "ezr"=>"ezra",
"nehemiah"=>"nehemiah",  "neh"=>"nehemiah", "ne"=>"nehemiah",
"esther"=>"esther",  "esth"=>"esther", "es"=>"esther",
"job"=>"job", "jb"=>"job",
"psalm"=>"psalm", "pslm"=>"psalm", "ps"=>"psalm", "psalms"=>"psalm", "psa"=>"psalm", "psm"=>"psalm", "pss"=>"psalm",
"proverbs"=>"proverbs",  "prov"=>"proverbs", "pr"=>"proverbs", "prv"=>"proverbs",
"ecclesiastes"=>"ecclesiastes",  "eccles"=>"ecclesiastes", "ec"=>"ecclesiastes", "ecc"=>"ecclesiastes", "qoh"=>"ecclesiastes", "qoheleth"=>"ecclesiastes",
"song of solomon"=>"song of solomon", "song"=>"song of solomon", "so"=>"song of solomon", "canticle of canticles"=>"song of solomon", "canticles"=>"song of solomon", "song of songs"=>"song of solomon", "sos"=>"song of solomon",
"isaiah"=>"isaiah",  "isa"=>"isaiah", "is"=>"isaiah",
"jeremiah"=>"jeremiah",  "jer"=>"jeremiah", "je"=>"jeremiah", "jr"=>"jeremiah",
"lamentations"=>"lamentations",  "lam"=>"lamentations", "la"=>"lamentations",
"ezekiel"=>"ezekiel", "ezek"=>"ezekiel", "eze"=>"ezekiel", "ezk"=>"ezekiel",
"daniel"=>"daniel",  "dan"=>"daniel", "da"=>"daniel", "dn"=>"daniel",
"hosea"=>"hosea", "hos"=>"hosea", "ho"=>"hosea",
"joel"=>"joel", "joe"=>"joel", "jl"=>"joel",
"amos"=>"amos",  "am"=>"amos",
"obadiah"=>"obadiah", "obad"=>"obadiah", "ob"=>"obadiah",
"jonah"=>"jonah", "jnh"=>"jonah", "jon"=>"jonah",
"micah"=>"micah",  "mic"=>"micah",
"nahum"=>"nahum", "nah"=>"nahum", "na"=>"nahum",
"habakkuk"=>"habakkuk",  "hab"=>"habakkuk",
"zephaniah"=>"zephaniah", "zeph"=>"zephaniah", "zep"=>"zephaniah", "zp"=>"zephaniah",
"haggai"=>"haggai",  "hag"=>"haggai", "hg"=>"haggai",
"zechariah"=>"zechariah", "zech"=>"zechariah", "zec"=>"zechariah", "zc"=>"zechariah",
"malachi"=>"malachi", "mal"=>"malachi", "ml"=>"malachi",
"tobit"=>"tobit",  "tob"=>"tobit", "tb"=>"tobit",
"judith"=>"judith",  "jdth"=>"judith", "jdt"=>"judith", "jth"=>"judith",
"additions to esther"=>"additions to esther", "add esth"=>"additions to esther", "add es"=>"additions to esther", "rest of esther"=>"additions to esther", "the rest of esther"=>"additions to esther", "aes"=>"additions to esther", "addesth"=>"additions to esther",
"wisdom of solomon"=>"wisdom of solomon", "wisd of sol"=>"wisdom of solomon", "wis"=>"wisdom of solomon", "ws"=>"wisdom of solomon", "wisdom"=>"wisdom of solomon",
"sirach"=>"sirach",  "sir"=>"sirach", "ecclesiasticus"=>"sirach", "ecclus"=>"sirach",
"baruch"=>"baruch",  "bar"=>"baruch",
"letter of jeremiah"=>"letter of jeremiah",  "let jer"=>"letter of jeremiah", "let jer"=>"letter of jeremiah", "lje"=>"letter of jeremiah", "ltr jer"=>"letter of jeremiah",
"song of three youths"=>"song of three youths",  "song of three"=>"song of three youths", "song thr"=>"song of three youths", "the song of three youths"=>"song of three youths", "pr az"=>"song of three youths", "prayer of azariah"=>"song of three youths", "azariah"=>"song of three youths", "the song of the three holy children"=>"song of three youths", "the song of three jews"=>"song of three youths", "song of the three holy children"=>"song of three youths", "song of thr"=>"song of three youths", "song of three children"=>"song of three youths", "song of three jews"=>"song of three youths",
"susanna"=>"susanna",  "sus"=>"susanna",
"bel and the dragon"=>"bel and the dragon",  "bel"=>"bel and the dragon",
"1 maccabees"=>"1 maccabees", "1 macc"=>"1 maccabees", "1 mac"=>"1 maccabees", "1m"=>"1 maccabees", "i ma"=>"1 maccabees", "1ma"=>"1 maccabees", "i mac"=>"1 maccabees", "1mac"=>"1 maccabees", "i macc"=>"1 maccabees", "1macc"=>"1 maccabees", "i maccabees"=>"1 maccabees", "1maccabees"=>"1 maccabees", "1st maccabees"=>"1 maccabees", "first maccabees"=>"1 maccabees",
"2 maccabees"=>"2 maccabees", "2 macc"=>"2 maccabees", "2 mac"=>"2 maccabees", "2m"=>"2 maccabees", "ii ma"=>"2 maccabees", "2ma"=>"2 maccabees", "ii mac"=>"2 maccabees", "2mac"=>"2 maccabees", "ii macc"=>"2 maccabees", "2macc"=>"2 maccabees", "ii maccabees"=>"2 maccabees", "2maccabees"=>"2 maccabees", "2nd maccabees"=>"2 maccabees", "second maccabees"=>"2 maccabees",
"1 esdras"=>"1 esdras",  "1 esdr"=>"1 esdras", "1 esd"=>"1 esdras", "i es"=>"1 esdras", "1es"=>"1 esdras", "i esd"=>"1 esdras", "1esd"=>"1 esdras", "i esdr"=>"1 esdras", "1esdr"=>"1 esdras", "i esdras"=>"1 esdras", "1esdras"=>"1 esdras", "1st esdras"=>"1 esdras", "first esdras"=>"1 esdras",
"prayer of manasseh"=>"prayer of manasseh",  "pr of man"=>"prayer of manasseh", "pr man"=>"prayer of manasseh", "pma"=>"prayer of manasseh", "prayer of manasses"=>"prayer of manasseh",
"additional psalm"=>"additional psalm",  "add psalm"=>"additional psalm", "add ps"=>"additional psalm",
"3 maccabees"=>"3 maccabees", "3 macc"=>"3 maccabees", "3 mac"=>"3 maccabees", "iii ma"=>"3 maccabees", "3ma"=>"3 maccabees", "iii mac"=>"3 maccabees", "3mac"=>"3 maccabees", "iii macc"=>"3 maccabees", "3macc"=>"3 maccabees", "iii maccabees"=>"3 maccabees", "3rd maccabees"=>"3 maccabees", "third maccabees"=>"3 maccabees",
"2 esdras"=>"2 esdras",  "2 esdr"=>"2 esdras", "2 esd"=>"2 esdras", "ii es"=>"2 esdras", "2es"=>"2 esdras", "ii esd"=>"2 esdras", "2esd"=>"2 esdras", "ii esdr"=>"2 esdras", "2esdr"=>"2 esdras", "ii esdras"=>"2 esdras", "2esdras"=>"2 esdras", "2nd esdras"=>"2 esdras", "second esdras"=>"2 esdras",
"4 maccabees"=>"4 maccabees", "4 macc"=>"4 maccabees", "4 mac"=>"4 maccabees", "iv ma"=>"4 maccabees", "4ma"=>"4 maccabees", "iv mac"=>"4 maccabees", "4mac"=>"4 maccabees", "iv macc"=>"4 maccabees", "4macc"=>"4 maccabees", "iv maccabees"=>"4 maccabees", "iiii maccabees"=>"4 maccabees", "4maccabees"=>"4 maccabees", "4th maccabees"=>"4 maccabees", "fourth maccabees"=>"4 maccabees",
"ode"=>"ode",
"psalms of solomon"=>"psalms of solomon", "ps solomon"=>"psalms of solomon", "ps sol"=>"psalms of solomon", "psalms solomon"=>"psalms of solomon", "pssol"=>"psalms of solomon",
"epistle to the laodiceans"=>"epistle to the laodiceans", "laodiceans"=>"epistle to the laodiceans", "laod"=>"epistle to the laodiceans", "ep laod"=>"epistle to the laodiceans", "epist laodiceans"=>"epistle to the laodiceans", "epistle laodiceans"=>"epistle to the laodiceans", "epistle to laodiceans"=>"epistle to the laodiceans",
"matthew"=>"matthew", "matt"=>"matthew", "mt"=>"matthew",
"mark"=>"mark",  "mrk"=>"mark", "mk"=>"mark", "mr"=>"mark",
"luke"=>"luke",  "luk"=>"luke", "lk"=>"luke",
"john"=>"john",  "jn"=>"john", "jhn"=>"john",
"acts"=>"acts",  "ac"=>"acts",
"romans"=>"romans",  "rom"=>"romans", "ro"=>"romans", "rm"=>"romans",
"1 corinthians"=>"1 corinthians", "1 cor"=>"1 corinthians", "1 co"=>"1 corinthians", "i co"=>"1 corinthians", "1co"=>"1 corinthians", "i cor"=>"1 corinthians", "1cor"=>"1 corinthians", "i corinthians"=>"1 corinthians", "1corinthians"=>"1 corinthians", "1st corinthians"=>"1 corinthians", "first corinthians"=>"1 corinthians",
"2 corinthians"=>"2 corinthians", "2 cor"=>"2 corinthians", "2 co"=>"2 corinthians", "ii co"=>"2 corinthians", "2co"=>"2 corinthians", "ii cor"=>"2 corinthians", "2cor"=>"2 corinthians", "ii corinthians"=>"2 corinthians", "2corinthians"=>"2 corinthians", "2nd corinthians"=>"2 corinthians", "second corinthians"=>"2 corinthians",
"galatians"=>"galatians", "gal"=>"galatians", "ga"=>"galatians",
"ephesians"=>"ephesians", "ephes"=>"ephesians", "eph"=>"ephesians",
"philippians"=>"philippians", "phil"=>"philippians", "php"=>"philippians",
"colossians"=>"colossians",  "col"=>"colossians",
"1 thessalonians"=>"1 thessalonians", "1 thess"=>"1 thessalonians", "1 th"=>"1 thessalonians", "i th"=>"1 thessalonians", "1th"=>"1 thessalonians", "i thes"=>"1 thessalonians", "1thes"=>"1 thessalonians", "i thess"=>"1 thessalonians", "1thess"=>"1 thessalonians", "i thessalonians"=>"1 thessalonians", "1thessalonians"=>"1 thessalonians", "1st thessalonians"=>"1 thessalonians", "first thessalonians"=>"1 thessalonians",
"2 thessalonians"=>"2 thessalonians", "2 thess"=>"2 thessalonians", "2 th"=>"2 thessalonians", "ii th"=>"2 thessalonians", "2th"=>"2 thessalonians", "ii thes"=>"2 thessalonians", "2thes"=>"2 thessalonians", "ii thess"=>"2 thessalonians", "2thess"=>"2 thessalonians", "ii thessalonians"=>"2 thessalonians", "2thessalonians"=>"2 thessalonians", "2nd thessalonians"=>"2 thessalonians", "second thessalonians"=>"2 thessalonians",
"1 timothy"=>"1 timothy", "1 tim"=>"1 timothy", "1 ti"=>"1 timothy", "i ti"=>"1 timothy", "1ti"=>"1 timothy", "i tim"=>"1 timothy", "1tim"=>"1 timothy", "i timothy"=>"1 timothy", "1timothy"=>"1 timothy", "1st timothy"=>"1 timothy", "first timothy"=>"1 timothy",
"2 timothy"=>"2 timothy", "2 tim"=>"2 timothy", "2 ti"=>"2 timothy", "ii ti"=>"2 timothy", "2ti"=>"2 timothy", "ii tim"=>"2 timothy", "2tim"=>"2 timothy", "ii timothy"=>"2 timothy", "2timothy"=>"2 timothy", "2nd timothy"=>"2 timothy", "second timothy"=>"2 timothy",
"titus"=>"titus",  "tit"=>"titus",
"philemon"=>"philemon",  "phil"=>"philemon", "phm"=>"philemon",
"hebrews"=>"hebrews",  "heb"=>"hebrews",
"james"=>"james", "jas"=>"james", "jm"=>"james",
"1 peter"=>"1 peter", "1 pet"=>"1 peter", "1 pe"=>"1 peter", "i pe"=>"1 peter", "1pe"=>"1 peter", "i pet"=>"1 peter", "1pet"=>"1 peter", "i pt"=>"1 peter", "1 pt"=>"1 peter", "1pt"=>"1 peter", "i peter"=>"1 peter", "1peter"=>"1 peter", "1st peter"=>"1 peter", "first peter"=>"1 peter",
"2 peter"=>"2 peter", "2 pet"=>"2 peter", "2 pe"=>"2 peter", "ii pe"=>"2 peter", "2pe"=>"2 peter", "ii pet"=>"2 peter", "2pet"=>"2 peter", "ii pt"=>"2 peter", "2 pt"=>"2 peter", "2pt"=>"2 peter", "ii peter"=>"2 peter", "2peter"=>"2 peter", "2nd peter"=>"2 peter", "second peter"=>"2 peter",
"1 john"=>"1 john",  "1 john"=>"1 john", "1 jn"=>"1 john", "i jn"=>"1 john", "1jn"=>"1 john", "i jo"=>"1 john", "1jo"=>"1 john", "i joh"=>"1 john", "1joh"=>"1 john", "i jhn"=>"1 john", "1 jhn"=>"1 john", "1jhn"=>"1 john", "i john"=>"1 john", "1john"=>"1 john", "1st john"=>"1 john", "first john"=>"1 john",
"2 john"=>"2 john",  "2 john"=>"2 john", "2 jn"=>"2 john", "ii jn"=>"2 john", "2jn"=>"2 john", "ii jo"=>"2 john", "2jo"=>"2 john", "ii joh"=>"2 john", "2joh"=>"2 john", "ii jhn"=>"2 john", "2 jhn"=>"2 john", "2jhn"=>"2 john", "ii john"=>"2 john", "2john"=>"2 john", "2nd john"=>"2 john", "second john"=>"2 john",
"3 john"=>"3 john",  "3 john"=>"3 john", "3 jn"=>"3 john", "iii jn"=>"3 john", "3jn"=>"3 john", "iii jo"=>"3 john", "3jo"=>"3 john", "iii joh"=>"3 john", "3joh"=>"3 john", "iii jhn"=>"3 john", "3 jhn"=>"3 john", "3jhn"=>"3 john", "iii john"=>"3 john", "3john"=>"3 john", "3rd john"=>"3 john", "third john"=>"3 john",
"jude"=>"jude",  "jud"=>"jude",
"revelation"=>"revelation",  "rev"=>"revelation", "re"=>"revelation", "the revelation"=>"revelation",
}
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

  @spec book_name(String.t) :: String.t
  def book_name(s), do: @book_names[s]

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
  end
end