require IEx
require Ecto.Query
alias Iphod.Repo
alias Iphod.Bible

defmodule LocalText do
  import RequestParser, only: [local_query: 1]
  import BookNames, only: [book_title: 1]
  import Ecto.Query, only: [from: 2]

  def passage(ver, book, chapter) do
    query = from Bible, where: [trans: ^ver, book: ^book, chapter: ^chapter]
    respond_with Repo.one(query), ver, book, chapter
    # resp.vss
  end

  def respond_with(nil, "web", book, chapter), do: "ERROR: Could not find passage #{book} #{chapter}"
  def respond_with(nil, _ver, book, chapter), do: passage("web", book, chapter)
  def respond_with(resp, _ver, _book, _chapter), do: resp.vss

  def passage(ver, book, chapter, from, to) do
    {from, to} = {from - 1, to - 1} # off by one
    passage(ver, book, chapter) 
      |> Enum.slice(from..to)
    #  |> Enum.reduce({[], from}, &([&1 | &2]))
    #  |> Enum.reverse
  end

  def request(ver, ref) do
    {_ver, _book, lists} = request(ver, local_query(ref), [])
    lists_to_html(lists, "<h3>#{titlize(String.downcase ref)}</h3>")
  end

  def request(ver, {book, []}, list), do: {ver, book, list}
  def request(ver, {book, [{chap, first, last}|t]}, list) do
    request(ver, {book, t}, list ++ [passage(ver, book, chap, first, last)])
  end

# if it's not a list, just send the string back
  def list_to_html(s), do: s

  def lists_to_html([], html), do: html

  def lists_to_html([h|t], html) do
    new_html = html <> "<p>" <> Enum.join(h, "</br>") <> "</p>"
    lists_to_html t, new_html
  end

  def titlize(ref) do
    list =  ref |> String.split
    contains_digit_list = list |> Enum.map(&(contains_digit? &1))
    {ok, title} = titlize(contains_digit_list, list)
    case ok do
      :ok -> title
      _ -> raise "Could not parse \"#{ref}\" as Biblical reference"
    end
  end

  def titlize([false], ref_list),                    do: _titlize ref_list, 1
  def titlize([true, false | _], ref_list),          do: _titlize ref_list, 2
  def titlize([false, true | _], ref_list),          do: _titlize ref_list, 1
  def titlize([false, false, false | _], ref_list),  do: _titlize ref_list, 3
  def titlize(_, _), do: {:error, ""}

  def _titlize(ref_list, n) when is_integer(n) do
    {book_name, vss} = ref_list |> Enum.split(n)
    {:ok, book_title(book_name |> Enum.join(" ")) <> " " <> (vss |> Enum.join)} 
  end

  def contains_digit?(s), do: s |> String.match?(~r/\d/)

  def makeKey(book, chap, vs) do
    key = if t = Regex.run( ~r/(\d)([A-Z]+)/, book) do
      [_, num, name] = t
      (name <> num) |> String.to_atom
    else
      book |> String.to_atom
    end
    %{  GEN: 1000000,  EXO: 2000000,  LEV: 3000000,  NUM: 4000000,  DEU:  5000000, JOS:  6000000,
        JDG: 7000000,  RUT: 8000000,  SA1: 9000000,  SA2: 10000000, KI1: 11000000, KI2: 12000000,
        CH1: 13000000, CH2: 14000000, EZR: 15000000, NEH: 16000000, EST: 17000000, JOB: 18000000,
        PSA: 19000000, PRO: 20000000, ECC: 21000000, SNG: 22000000, ISA: 23000000, JER: 24000000,
        LAM: 25000000, EZK: 26000000, DAN: 27000000, HOS: 28000000, JOL: 29000000, AMO: 30000000,
        OBA: 31000000, JON: 32000000, MIC: 33000000, NAM: 34000000, HAB: 35000000, ZEP: 36000000,
        HAG: 37000000, ZEC: 38000000, MAL: 39000000, 
        MAT: 40000000, MRK: 41000000, LUK: 42000000, JHN: 43000000, ACT: 44000000, ROM: 45000000, 
        CO1: 46000000, CO2: 47000000, GAL: 48000000, EPH: 49000000, PHP: 50000000, COL: 51000000, 
        TH1: 52000000, TH2: 53000000, TI1: 54000000, TI2: 55000000, TIT: 56000000, PHM: 57000000, 
        HEB: 58000000, JAS: 59000000, PE1: 60000000, PE2: 61000000, JN1: 62000000, JN2: 63000000, 
        JN3: 64000000, JUD: 65000000, REV: 66000000, 
        TOB: 67000000, JDT: 68000000, ESG: 69000000, WIS: 70000000, SIR: 71000000, BAR: 72000000, 
        ES1: 73000000, MAN: 74000000, PS2: 75000000, MA1: 76000000, MA2: 77000000, MA3: 78000000, 
        ES2: 79000000, MA4: 80000000, DAG: 81000000, 
        FRT: 82000000, GLO: 83000000
      }[key] + (chap * 1000) + vs;
  end

  def all_books(trans \\ "web") do
    query = from b in Bible, where: b.trans == ^trans
    Repo.all query
  end

  def versify_books() do
    versify_books(all_books, [])
  end

  def versify_books([], vss) do
    vss
  end

  def versify_books([h|t], vss) do
    versify_books(t, versify_chapter(h, 1, vss) )
  end

  def versify_chapter(chapter, num, vss) do
    _versify_chapter(chapter.book, chapter.chapter, num, chapter.vss, vss)
  end

  def _versify_chapter(_book, _chapter, _num, [], vss) do
    vss
  end

  def _versify_chapter(book, chapter, num, [h|t], vss)do
    # [_, vs] = Regex.run ~r/V(\d+)/, h ## extract the verse numner
    map = %{id: makeKey(book, chapter, num),
            book: book,
            chap: chapter,
            vs: num,
            vss: h
          }
    IO.puts inspect(map)
    _versify_chapter(book, chapter, num + 1, t, [ map | vss])
  end
end