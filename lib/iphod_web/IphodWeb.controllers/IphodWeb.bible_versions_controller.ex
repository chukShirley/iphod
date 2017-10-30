defmodule IphodWeb.BibleVersionsController do
  use IphodWeb, :controller

  def index(conn, _params) do
    # IEx.pry
    render conn, "index.html", page_controller: "bible_versions"
  end

#   def index(conn, params) do
#     model = BibleVersions.list_all
#       |> Enum.map( fn({id, abbr, name, lang})-> 
#           %{language: lang, abbr: abbr, name: name, id: id}
#         end) 
#       |> Enum.sort(&(&1.language < &2.language))
#     render conn, "index.html", model: model   
#   end
end