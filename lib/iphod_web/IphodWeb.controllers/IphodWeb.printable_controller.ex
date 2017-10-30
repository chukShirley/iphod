defmodule IphodWeb.PrintableController do
  use IphodWeb, :controller

  def index(conn, _params) do
    docs = Printable.identity
      |> Enum.map( fn({name, format, form, description})->
          %{name: name, format: format, form: form, description: description}
        end)
    render conn, "index.html", page_controller: "printable", docs: docs
  end

end
