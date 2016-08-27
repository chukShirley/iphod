ExUnit.start
defmodule EsvTextTest do
  import EsvText
  use ExUnit.Case

  test "sanity" do
    assert true, "insane if fails"
  end

  test "esv_url for single chapter" do
    url = esv_url("psalm 112")
    assert url |> String.contains?("psalms+112"), "URL WAS\n#{url}"
  end
  test "esv_url for chapter with verses" do
    url = esv_url("psalm 112:1-6")
    assert url |> String.contains?("psalms+112.1-6"), "URL WAS\n#{url}"
  end
  test "esv_url for single chapter with multiple sections" do
    url = esv_url("psalm 112:1-6, 8-10")
    assert url |> String.contains?("psalms+112.1-6+112.8-10"), "URL WAS\n#{url}"
  end

end