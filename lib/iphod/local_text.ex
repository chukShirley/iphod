require IEx
require Ecto.Query
alias Iphod.Repo
alias Iphod.Bible

defmodule LocalText do
  import RequestParser, only: [local_query: 1]
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
    {ver, book, lists} = request(ver, local_query(ref), [])
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
    new_html = html <> "<p>" <> Enum.join(h, "</br>") <> "</p>"
    lists_to_html t, new_html
  end


end