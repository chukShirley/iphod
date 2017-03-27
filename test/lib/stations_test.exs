defmodule Iphod.StationsTest do
  use ExUnit.Case, async: false
  use Plug.Test

  test "sanity" do
    assert (1 + 1) == 2
  end

  test "before returns text list of two versicals" do
    assert Stations.before() == [ "We adore you, O Christ, and we bless you.",
                                  "Because of your holy cross you have redeemed the world."
                                ]
  end

  test "before w/ arg returns proper versical" do
    assert Stations.before("Minister") == "We adore you, O Christ, and we bless you."
    assert Stations.before("All") == "Because of your holy cross you have redeemed the world."
  end

  test "after returns proper list of versicals" do
    assert Stations.afterStation() == ["Lord Jesus, help us walk in your steps."]
  end

  test "after w/ arg returns proper versical" do
    assert Stations.afterStation("All") == "Lord Jesus, help us walk in your steps."
  end

  test "before and after return empty string w/ incorrect arg" do
    assert Stations.before("blork") == ""
    assert Stations.afterStation("blork") == ""
  end
end