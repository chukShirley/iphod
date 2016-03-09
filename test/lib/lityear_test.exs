defmodule Iphod.LitYearTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use Timex
  import Lityear
  import Mock
  alias Iphod.LitYear


  test "the truth" do
    assert (1 + 1) == 2
  end

#  setup day do
#    today       = Date.from {2015,3,17}
#    next_sunday = Date.from {2015,3,22}
#    last_year   = Date.from {2014,3,17}
#    christmas   = Date.from {2015,12,25}
#    advent1     = Date.from {2016,11,27} 
#  end
    

  test "days till sunday" do
    monday    = Date.from {2016, 3, 7}
    tuesday   = Date.from {2016, 3, 8}
    wednesday = Date.from {2016, 3, 9}
    thursday  = Date.from {2016, 3, 10}
    friday    = Date.from {2016, 3, 11}
    saturday  = Date.from {2016, 3, 12}
    sunday    = Date.from {2016, 3, 13}
    assert days_till_sunday(monday) == 6
    assert days_till_sunday(tuesday) == 5
    assert days_till_sunday(wednesday) == 4
    assert days_till_sunday(thursday) == 3
    assert days_till_sunday(friday) == 2
    assert days_till_sunday(saturday) == 1
    assert days_till_sunday(sunday) == 7
  end

  test "lityear returns the proper liturgical year" do
    today       = Date.from {2015,3,17}
    christmas   = Date.from {2015,12,25}
    advent1     = Date.from {2016,11,27} 
    assert lityear(today) == 2015
    assert lityear(advent1) == 2017
    assert lityear(christmas) == 2016
  end

  test "abc() returns correct year letter" do
    today       = Date.from {2015,3,17}
    last_year   = Date.from {2014,3,17}
    christmas   = Date.from {2015,12,25}
    advent1     = Date.from {2016,11,27} 
    assert abc(today) == "B"
    assert abc(christmas) == "C"
    assert abc(last_year) == "A"
    assert abc(advent1) == "A"
  end

  test "abc_atom() returns correct year atom" do
    today       = Date.from {2015,3,17}
    last_year   = Date.from {2014,3,17}
    christmas   = Date.from {2015,12,25}
    advent1     = Date.from {2016,11,27} 
    assert abc_atom(today) == :b
    assert abc_atom(christmas) == :c
    assert abc_atom(last_year) == :a
    assert abc_atom(advent1) == :a
  end

  test "next_sunday returns easter" do
#   easter(2014) == Date.from {2014, 4, 20}
    assert next_sunday(Date.from {2014, 4, 15}) === {"easterDay", "1", :a}
  end
  test "next_sunday returns palm sunday" do
    assert next_sunday(Date.from {2014, 4, 8}) === {"palmSunday", "1", :a}
  end
  test "next_sunday returns lent" do
    assert next_sunday(Date.from {2016, 2, 9}) == {"lent", "1", :c}
  end
  test "next_sunday returns sundays in easter" do
    assert next_sunday(Date.from {2016, 3, 28}) == {"easter", "2", :c}
  end
  test "next_sunday returns pentecost" do
    assert next_sunday(Date.from {2016, 5, 14}) == {"proper", "1", :c}
  end
  test "next_sunday returns proper" do
    assert next_sunday(Date.from {2016, 5, 27}) == {"proper", "4", :c}
    assert next_sunday(Date.from {2016, 11, 16}) == {"proper", "29", :c}
  end
  test "next_sunday returns advent" do
    assert next_sunday(Date.from {2016, 11, 25}) == {"advent", "1", :a}
    assert next_sunday(Date.from {2016, 12, 16}) == {"advent", "4", :a}
  end

  test "next_sunday returns christmas 1" do
    christmas_on_mon = christmas(2017) # B
    christmas_on_tue = christmas(2018) # C
    christmas_on_wed = christmas(2013) # A
    christmas_on_thu = christmas(2014) # B
    christmas_on_fri = christmas(2015) # C
    christmas_on_sat = christmas(2021) # C
    christmas_on_sun = christmas(2016) # A
    assert next_sunday(christmas_on_mon) == {"christmas", "1", :b}
    assert next_sunday(christmas_on_tue) == {"christmas", "1", :c}
    assert next_sunday(christmas_on_wed) == {"christmas", "1", :a}
    assert next_sunday(christmas_on_thu) == {"christmas", "1", :b}
    assert next_sunday(christmas_on_fri) == {"christmas", "1", :c}
    assert next_sunday(christmas_on_sat) == {"christmas", "1", :c}
    assert next_sunday(christmas_on_sun) == {"holyName", "1", :a}
  end

  test "next_sunday returns christmas 2" do
    christmas_on_mon = date_next_sunday christmas(2017) # B
    christmas_on_tue = date_next_sunday christmas(2018) # C
    christmas_on_wed = date_next_sunday christmas(2013) # A
    christmas_on_thu = date_next_sunday christmas(2014) # B
    christmas_on_fri = date_next_sunday christmas(2015) # C
    christmas_on_sat = date_next_sunday christmas(2021) # C
    christmas_on_sun = date_next_sunday christmas(2016) # A
    assert next_sunday(christmas_on_mon) == {"epiphany", "1", :b}
    assert next_sunday(christmas_on_tue) == {"theEpiphany", "1", :c}
    assert next_sunday(christmas_on_wed) == {"christmas", "2", :a}
    assert next_sunday(christmas_on_thu) == {"christmas", "2", :b}
    assert next_sunday(christmas_on_fri) == {"christmas", "2", :c}
    assert next_sunday(christmas_on_sat) == {"christmas", "2", :c}
    assert next_sunday(christmas_on_sun) == {"epiphany", "1", :a}
  end

  test "next_sunday returns epiphany" do
    assert next_sunday(Date.from {2018,1,6})  == {"epiphany", "1", :b}
    assert next_sunday(Date.from {2018,1,20}) == {"epiphany", "3", :b}
    assert next_sunday(Date.from {2018,2,10}) == {"epiphany", "9", :b}
    assert next_sunday(Date.from {2018,2,3})  == {"epiphany", "8", :b}
  end

  test "lityear returns sundays" do
    today       = Date.from {2015,3,17}
    next_sunday = Date.from {2015,3,22}
    last_sunday = Date.from {2015,3,15}
    refute( is_sunday?(today))
    assert( is_sunday?(next_sunday))
    assert( is_sunday?(last_sunday))
    assert( date_next_sunday(today) == next_sunday)
    assert( date_last_sunday(today) == last_sunday)
  end

  test "next_holy_day returns correct date" do
    assert next_holy_day(Date.from {2016, 3, 6}) == {stJoseph, "stJoseph"} # leap year
    assert next_holy_day(Date.from {2017, 3, 6}) == {stJoseph( 2017), "stJoseph"}
    assert next_holy_day(Date.from {2016, 1, 2}) == {confessionOfStPeter, "confessionOfStPeter"}
    assert next_holy_day(Date.from {2017, 1, 2}) == {confessionOfStPeter( 2017), "confessionOfStPeter"}
    assert next_holy_day(Date.from {2016, 9, 15}) == {stMatthew, "stMatthew"}
    assert next_holy_day(Date.from {2017, 9, 15}) == {stMatthew( 2017), "stMatthew"}
    assert next_holy_day(Date.from {2016, 12, 30}) == {confessionOfStPeter( 2017), "confessionOfStPeter"}
    assert next_holy_day(Date.from {2017, 12, 30}) == {confessionOfStPeter( 2018), "confessionOfStPeter"}
  end

  test "lityear gives correct advent dates" do
    year = 2015
    christmas_date = Date.from {year,12,25}
    refute is_sunday?(christmas_date)
    assert advent(4, year) == christmas_date |> date_last_sunday
  end

  test "finding epiphany not on sunday" do
    epiphany1 = Date.from {2015,1,11}
    assert epiphany(0) == {:error, "There is no Epiphany before year 0."}
    assert epiphany(1, 2015) == epiphany1
  end

# from http://tlarsen2.tripod.com/thomaslarsen/easterdates.html
# 20th April 2014   10th April 2039    6th April 2064    3rd April 2089
#  5th April 2015    1st April 2040   29th March 2065   16th April 2090
# 27th March 2016   21st April 2041   11th April 2066    8th April 2091
# 16th April 2017    6th April 2042    3rd April 2067   30th March 2092
  test "finding Easter" do
    assert easter(2014) == Date.from {2014, 4, 20}
    assert easter(2015) == Date.from {2015, 4,  5}
    assert easter(2016) == Date.from {2016, 3, 27}
    assert easter(2017) == Date.from {2017, 4, 16}
    assert easter(2039) == Date.from {2039, 4, 10}
    assert easter(2040) == Date.from {2040, 4,  1}
    assert easter(2041) == Date.from {2041, 4, 21}
    assert easter(2042) == Date.from {2042, 4,  6}
    assert easter(2064) == Date.from {2064, 4,  6}
    assert easter(2065) == Date.from {2065, 3, 29}
    assert easter(2066) == Date.from {2066, 4, 11}
    assert easter(2067) == Date.from {2067, 4,  3}
    assert easter(2089) == Date.from {2089, 4,  3}
    assert easter(2090) == Date.from {2090, 4, 16}
    assert easter(2091) == Date.from {2091, 4,  8}
    assert easter(2092) == Date.from {2092, 3, 30}
  end

  test "finding ash wednesday" do
    assert ash_wednesday(2016) == Date.from {2016, 2, 10}
  end

  test "finding first sunday in lent" do
    assert lent(1, 2016) == Date.from {2016, 2, 14}
    assert lent(1) == lent(1, Date.local.year)
  end

  test "finding pentecost" do
    assert pentecost(1, 2016) == Date.from {2016, 5, 15}
    assert pentecost(1) == pentecost(1, Date.local.year)
  end

  test "finding the proper" do
    assert proper(29, 2016) == Date.from {2016, 11, 20}
    assert proper(2, 2016) == pentecost(1, 2016)
    assert proper(29) == proper(29, Date.local.year)
  end

  test "finding thanksgiving" do
    assert thanksgiving(2012) == Date.from {2012, 11, 22}
    assert thanksgiving(2013) == Date.from {2013, 11, 28}
    assert thanksgiving(2014) == Date.from {2014, 11, 27}
    assert thanksgiving(2015) == Date.from {2015, 11, 26}
    assert thanksgiving(2016) == Date.from {2016, 11, 24}
    assert thanksgiving(2017) == Date.from {2017, 11, 23}
    assert thanksgiving(2022) == Date.from {2022, 11, 24}
    assert thanksgiving(2021) == Date.from {2021, 11, 25}
  end

  test "finding memorial day" do
    assert memorial(2016) == Date.from {2016, 5, 30}
    assert memorial(2017) == Date.from {2017, 5, 29}
    assert memorial(2018) == Date.from {2018, 5, 28}
    assert memorial(2019) == Date.from {2019, 5, 27}
    assert memorial(2020) == Date.from {2020, 5, 25}
    assert memorial(2021) == Date.from {2021, 5, 31}
    assert memorial(2025) == Date.from {2025, 5, 26}
    assert memorial(2026) == Date.from {2026, 5, 25}
  end
  
end
