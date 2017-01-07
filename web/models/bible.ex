require IEx
alias Iphod.Repo
defmodule Iphod.Bible do
  use Iphod.Web, :model
  @trans "cu89s"
  @name "Chinese Union Simplified"
  @direction "LTR"


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

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [@required_fields, @optional_fields, :bible])
    |> unique_constraint(:bible, name: :bible_trans_book_chapter_index)
  end

  def load(map) do
    chapter = 1
    name = map.translation
    type = map.type
    trans = map.version_ref
    direction = map.direction
    map.book 
      |> Map.keys
      |> Enum.each( fn(bk)->
        map.book[bk] |> Enum.reduce( 1, fn(vss, chapter)->
          IO.puts "#{bk}: #{chapter}"
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

#   def load(s) do
#     {:ok, file} = File.open(s, [:read, :utf8])
#     map = 
#       IO.read(file, :all)
#       |> to_string()
#       |> Poison.Parser.parse()
#     IEx.pry
#     direction = map["direction"]
#     trans = map["version_ref"]
#     name = map["translation"]
#     :ok = map["version"] 
#       |> Map.keys
#       |> Enum.each( fn(bk_id)->
#         book_name = map["version"][bk_id]["book_name"]
#         map["version"][bk_id]["book"]
#           |> Map.keys
#           |> Enum.each( fn(chapter) -> 
#             vss = vs_list( map["vedrsion"][bk_id]["book"][chapter]["chapter"])
#             case Repo.insert( 
#               %Iphod.Bible{ trans: trans, 
#                       name: name, 
#                       direction: direction, 
#                       book: book_name,
#                       chapter: chapter,
#                       vss: vss}) do
#               {:ok, _} -> 
#                 :ok
#               {:error, changeset} ->
#                 IEx.pry
#                 :error
#             end
# 
#           end)
#       end)
#       File.close(file)
#   end

#   def vs_list(map) do
#     map |> Map.keys
#       Enum.map(fn(v) ->
#         "<span class='vs_number'>#{v}</span> #{map[v]["verse"]}"
#       end)
#   end
end