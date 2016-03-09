require IEx
defmodule Psalms do

  def start_link do
    Agent.start_link fn -> build end, name: __MODULE__
  end

  def build do
    import String
    File.open!("./data/psalms.txt", [:read, :utf8])
      |> IO.stream(:line)
      |> Enum.reduce(%{}, fn(ln, pss)-> 
        ln
          |> split("|")
          |> Enum.map(&strip(&1))
          |> _build(pss)
        end)
  end

  def _build(["119"|therest], struct) do
    struct 
  end

  def _build([id, name, title|vss], struct) do
    struct |> Map.put(id, %{name: name, title: title, vss: build_vss(vss)})
  end

  def build_vss(vss), do: build_vss(vss, %{})
  def build_vss([], verses), do: verses
  def build_vss([vs, start, finish|tail], verses) do
    build_vss tail, verses |> Map.put(vs, %{start: start, finish: finish})
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
#  def psalm(n) when n |> is_integer, do: identity[to_string n]
  def psalm(n), do: identity[to_string n]

end

# defmodule PsVerse do
#   defstruct vs: 0,
#             start: "",
#             finish: "",
# end
# defmodule Psalm do
#   defstruct id: "",
#             name: "",
#             title: "",
#             vss: %{}
# end