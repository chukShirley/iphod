defmodule Iphod.LeafletsTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use Timex
  import Leaflets
  alias Iphod.Lityear

  test "sanity" do
    assert (1+1) == 2
  end

  test "returns map of two empty string if undefined" do
    resp = Leaflets.for_this_sunday("advent", "1", "c")
    assert (resp) == %{ reg: "", lp: "" }
  end

  test "returns map w/ two urls if defined" do
    resp = Leaflets.for_this_sunday("proper", "1", "a")
    expected = %{ reg: "https://s3.amazonaws.com/acna/A-43-May%208-Pentecost%20landscape-2.pdf", 
                  lp:  "https://s3.amazonaws.com/acna/A-43-May%208-Pentecost-2pdf"
                }
    assert (resp) == expected
  end

  test "returns proper 8 map for Sunday, June 2, 2017" do
    day = ~D[2017-07-02]
    resp = Leaflets.for_this_date(day)
    expected = %{ reg: "https://s3.amazonaws.com/acna/A-50-After-Pentecost-6-26-7-2-landscape-2.pdf", 
                  lp:  "https://s3.amazonaws.com/acna/A-50-After-Pentecost-6-26-7-2pdf" 
                }
    assert (resp) == expected
  end
  
  test "returns proper 8 map for Monday, June 3, 2017" do
    day = ~D[2017-07-03]
    resp = Leaflets.for_this_date(day)
    expected = %{ reg: "https://s3.amazonaws.com/acna/A-50-After-Pentecost-6-26-7-2-landscape-2.pdf", 
                  lp:  "https://s3.amazonaws.com/acna/A-50-After-Pentecost-6-26-7-2pdf" 
                }
    assert (resp) == expected
  end
end