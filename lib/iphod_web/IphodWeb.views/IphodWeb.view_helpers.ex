require IEx

defmodule ViewHelpers do
  use IphodWeb, :view

  def markdown(s) do
    s |> Earmark.to_html() |> raw
  end

  def text_list_to_html(model) do
    s =
      model
      |> Enum.reduce("", fn el, acc -> acc <> el.body end)

    # remove newlines, they screw up the html
    Regex.replace(~r/\n/, "<div>" <> s <> "</div>", "")
    |> Earmark.to_html()
    |> raw
  end
end
