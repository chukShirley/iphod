defmodule IphodWeb.DisplayHelpers do
  @moduledoc """
  Conveniences for formatting stuff on the page.
  """
  
  use Phoenix.HTML

  @doc """
  shorten string and add `...` at the end
  """
  def ellipsis(s, len), do: String.slice(s, 0, len) <> "..."

end