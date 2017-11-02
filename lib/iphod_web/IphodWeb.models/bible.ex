require IEx
alias Iphod.Repo
defmodule Iphod.Bible do
  use IphodWeb, :model
  # @trans "cu89s"
  # @name "Chinese Union Simplified"
  # @direction "LTR"


  schema "bible" do
      field :trans, :string
      field :name, :string
      field :direction, :string, default: "LTR"
      field :book, :string
      field :chapter, :integer
      field :vss, {:array, :string}
  end

  @required_fields ~w(trans name book chapter vss)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [@required_fields, @optional_fields, :bible])
    |> unique_constraint(:bible, name: :bible_trans_book_chapter_index)
  end

  def load(map) do
    name = map.translation
    type = map.type
    trans = map.version_ref
    direction = map.direction
    map.book 
      |> Map.keys
      |> Enum.each( fn(bk)->
        map.book[bk] |> Enum.reduce( 1, fn(vss, chapter)->
          case Repo.insert( %Iphod.Bible {
            trans: trans,
            name: name,
            direction: direction,
            book: bk,
            chapter: chapter,
            vss: vss
            }) do
             {:ok, _} -> :ok
             {:error, resp} ->
              IEx.pry
              :error
            end
          chapter + 1
        end)
      end)
  end

end