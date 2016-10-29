require IEx
require Ecto.Query
alias Iphod.Repo
alias Iphod.Bible

defmodule LocalText do
  import RequestParser, only: [local_query: 1]
  import BookNames, only: [book_name: 1, book_title: 1]
  import Ecto.Query, only: [from: 2]

  def passage(ver, book, chapter) do
    query = from Bible, where: [trans: ^ver, book: ^book, chapter: ^chapter]
    respond_with Repo.one(query), ver, book, chapter
    # resp.vss
  end

  def respond_with(nil, "web", book, chapter), do: "ERROR: Could not find passage #{book} #{chapter}"
  def respond_with(nil, ver, book, chapter), do: passage("web", book, chapter)
  def respond_with(resp, _ver, _book, _chapter), do: resp.vss

  def passage(ver, book, chapter, from, to) do
    {from, to} = {from - 1, to - 1} # off by one
    passage(ver, book, chapter) 
      |> Enum.slice(from..to)
    #  |> Enum.reduce({[], from}, &([&1 | &2]))
    #  |> Enum.reverse
  end

  def request(ver, ref) do
    {ver, book, lists} = request(ver, local_query(ref), [])
    lists_to_html(lists, "<h3>#{titlize(ref)}</h3>")
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
    Regex.replace ~r/(\d?\s?\w+)/, ref, &(book_title(&1)), global: false
  end


end