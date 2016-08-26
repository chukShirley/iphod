require IEx
defmodule ViewHelpers do
  use Iphod.Web, :view
  def markdown(s) do
    s |> Earmark.to_html |> raw
  end

  def text_list_to_html(model) do
    s = model
      |> Enum.reduce("", fn(el, acc)-> acc = acc <> el.body end)
  # remove newlines, they screw up the html
    Regex.replace(~r/\n/, "<div>" <> s <> "</div>", "")
      |> Earmark.to_html
      |> raw
  end
end