defmodule BibleText do

  def lesson_with_body(list), do: lesson_with_body(list, "ESV")
  
  def lesson_with_body(list, "ESV") do
    list |> Enum.map(fn(lesson)->
      lesson 
      |> Map.put(:body, EsvText.request(lesson.read) )
      |> Map.put(:show, true)
    end)
  end

  def lesson_with_body(list, ver) do
    lesson_with_body(list, ver, BibleVersions.source(ver))
  end

  def lesson_with_body(list, ver, "bibles.org") do
    list |> Enum.map(fn(lesson)->
      lesson 
      |> Map.put(:body, BibleComText.request(ver, lesson.read) )
      |> Map.put(:show, true)
    end)
  end

  def lesson_with_body(list, ver, "getbible.net") do
    list |> Enum.map(fn(lesson)->
      lesson 
      |> Map.put(:body, GetBibleText.request(ver, lesson.read) )
      |> Map.put(:show, true)
    end)
  end

end