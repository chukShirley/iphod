defmodule Iphod.BibleVersionsController do
  use Iphod.Web, :controller

  def index(conn, params) do
    model = BibleVersions.list_all
      |> Enum.map( fn({id, abbr, name, lang})-> 
          %{language: lang, abbr: abbr, name: name, id: id}
        end) 
      |> Enum.sort(&(&1.language < &2.language))
    render conn, "index.html", model: model   
  end
end