require IEx
defmodule BibleText do

  def selection(vss, ver, section) do
    lesson_with_body(
      [ %{ body: "",
        id: Regex.replace(~r/[\s\.]/, vss, "_"),
        read: vss,
        section: section,
        show: true,
        style: "req",
        version: ver
      }], ver)
  end


  def lesson(list, ver \\ "ESV") do
    lesson_with_body(list, ver)
      |> Enum.reduce([], &(&2 ++ [&1.body]))
  end

#  def lesson_with_body(vss, "") when vss |> is_bitstring do
#    lesson_with_body vss, "ESV"
#  end
#
#  def lesson_with_body(vss, ver) when vss |> is_bitstring do
#    lesson_with_body [vss], "ESV"
#  end

  def lesson_with_body(list), do: lesson_with_body(list, "ESV")
  
  def lesson_with_body(list, "ESV") do
    list |> Enum.map(fn(lesson)->
      lesson 
        |> Map.put(:body, EsvText.request(lesson.read) )
        |> other_init_values
    end)
  end

  def lesson_with_body(list, ver) do
    lesson_with_body(list, ver, BibleVersions.source(ver))
  end

  def lesson_with_body(list, ver, "Coverdale") do
    list |> Enum.map(fn(lesson)->
      lesson
        |> Map.put(:body, Psalms.to_html(lesson.read, "Coverdale"))
        |> other_init_values
    end)
  end

  def lesson_with_body(list, ver, "BCP") do
    list |> Enum.map(fn(lesson)->
      lesson
        |> Map.put(:body, Psalms.to_html(lesson.read, "BCP"))
        |> other_init_values
    end)
  end

  def lesson_with_body(list, ver, "bibles.org") do
    list |> Enum.map(fn(lesson)->
      lesson 
      |> Map.put(:body, BibleComText.request(ver, lesson.read) )
      |> other_init_values
    end)
  end

  def lesson_with_body(list, ver, "getbible.net") do
    list |> Enum.map(fn(lesson)->
      lesson 
      |> Map.put(:body, GetBibleText.request(ver, lesson.read) )
      |> other_init_values
    end)
  end

  def lesson_with_body(list, ver, "local") do
    list |> Enum.map(fn(lesson)->
      lesson 
      |> Map.put(:body, LocalText.request(ver, lesson.read) )
      |> other_init_values
    end)
  end

  def other_init_values(map) do
    map
      |> Map.put(:altRead, "")
      |> Map.put(:cmd, "")
      |> Map.put(:show, true)
      |> Map.put(:notes, [])
  end

end