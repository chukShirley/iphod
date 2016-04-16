defmodule Iphod.PrintableController do
  use Iphod.Web, :controller

  def index(conn, params) do
    docs = Printable.identity
      |> Enum.map( fn({name, format, form, description})->
          %{name: name, format: format, form: form, description: description}
        end)
    render conn, "index.html", docs: docs
  end

end
