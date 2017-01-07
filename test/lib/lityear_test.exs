defmodule Iphod.LitYearTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use Timex
  import Lityear
  alias Iphod.Lityear

  def dateFrom(yr, mon, day) do
    Timex.to_date({yr, mon, day})  
  end

  test "the truth" do
    assert (1 + 1) == 2
  end

#  setup day do
#    today       = dateFrom 2015,3,17
#    next_sunday = dateFrom 2015,3,22
#    last_year   = dateFrom 2014,3,17
#    christmas   = dateFrom 2015,12,25
#    advent1     = dateFrom 2016,11,27}
#  end
    
  test "leap_year_correction?" do
    assert Timex.is_leap?(2016)
    refute leap_year_correction?(dateFrom 2016, 2, 29)
    assert leap_year_correction?(dateFrom 2016, 3, 1)
    refute leap_year_correction?(dateFrom 2017, 3, 1)
  end

  test "days till sunday" do
    monday    = dateFrom 2016, 3, 7
    tuesday   = dateFrom 2016, 3, 8
    wednesday = dateFrom 2016, 3, 9
    thursday  = dateFrom 2016, 3, 10
    friday    = dateFrom 2016, 3, 11
    saturday  = dateFrom 2016, 3, 12
    sunday    = dateFrom 2016, 3, 13
    assert days_till_sunday(monday) == 6
    assert days_till_sunday(tuesday) == 5
    assert days_till_sunday(wednesday) == 4
    assert days_till_sunday(thursday) == 3
    assert days_till_sunday(friday) == 2
    assert days_till_sunday(saturday) == 1
    assert days_till_sunday(sunday) == 7
  end

  test "lityear returns the proper liturgical year" do
    today       = dateFrom 2015,3,17
    christmas   = dateFrom 2015,12,25
    advent1     = dateFrom 2016,11,27
    assert lityear(today) == 2015
    assert lityear(advent1) == 2017
    assert lityear(christmas) == 2016
  end

  test "abc() returns correct year letter" do
    today       = dateFrom 2015,3,17
    last_year   = dateFrom 2014,3,17
    christmas   = dateFrom 2015,12,25
    advent1     = dateFrom 2016,11,27
    assert abc(today) == "b"
    assert abc(christmas) == "c"
    assert abc(last_year) == "a"
    assert abc(advent1) == "a"
  end

  test "abc_atom() returns correct year atom" do
    today       = dateFrom 2015,3,17
    last_year   = dateFrom 2014,3,17
    christmas   = dateFrom 2015,12,25
    advent1     = dateFrom 2016,11,27
    assert abc_atom(today) == :b
    assert abc_atom(christmas) == :c
    assert abc_atom(last_year) == :a
    assert abc_atom(advent1) == :a
  end

  test "next_sunday returns easter" do
#   easter(2014) == dateFrom 2014, 4, 20
    date = dateFrom 2014, 4, 15
    assert next_sunday(date) === {"easterDay", "1", "a", dateFrom( 2014, 4, 20)}
  end
  test "next_sunday returns palm sunday" do
    tuesday = dateFrom 2014, 4, 8
    palmSunday = dateFrom 2014, 4, 13
    assert next_sunday(tuesday) === {"palmSunday", "1", "a", palmSunday}
  end
  test "next_sunday returns lent" do
    tuesday = dateFrom 2016, 2, 9
    sunday = dateFrom 2016, 2, 14
    assert next_sunday(tuesday) == {"lent", "1", "c", sunday}
  end
  test "next_sunday returns sundays in easter" do
    monday = dateFrom 2016, 3, 28
    sunday = dateFrom 2016, 4, 3
    assert next_sunday(monday) == {"easter", "2", "c", sunday}
  end
  test "next_sunday returns pentecost" do
    saturday = dateFrom 2016, 5, 14
    sunday = dateFrom 2016, 5, 15
    assert next_sunday(saturday) == {"pentecost", "1", "c", sunday}
  end
  test "next_sunday returns proper" do
    friday = dateFrom 2016, 5, 27
    sunday = dateFrom 2016, 5, 29
    assert next_sunday(friday) == {"proper", "4", "c", sunday}
    wednesday = dateFrom 2016, 11, 16
    sunday = dateFrom 2016, 11, 20
    assert next_sunday(wednesday) == {"proper", "29", "c", sunday}
  end
  test "next_sunday returns advent" do
    date = dateFrom 2016, 11, 25
    assert next_sunday(date) == {"advent", "1", "a", dateFrom( 2016, 11, 27)}
    date = dateFrom 2016, 12, 16
    assert next_sunday(date) == {"advent", "4", "a", dateFrom( 2016, 12, 18)}
  end

  test "next_sunday returns christmas 1" do
    christmas_on_mon = christmas(2017) # B
    christmas_on_tue = christmas(2018) # C
    christmas_on_wed = christmas(2013) # A
    christmas_on_thu = christmas(2014) # B
    christmas_on_fri = christmas(2015) # C
    christmas_on_sat = christmas(2021) # C
    assert next_sunday(christmas_on_mon) == {"christmas", "1", "b", dateFrom( 2017, 12, 31)}
    assert next_sunday(christmas_on_tue) == {"christmas", "1", "c", dateFrom( 2018, 12, 30)}
    assert next_sunday(christmas_on_wed) == {"christmas", "1", "a", dateFrom( 2013, 12, 29)}
    assert next_sunday(christmas_on_thu) == {"christmas", "1", "b", dateFrom( 2014, 12, 28)}
    assert next_sunday(christmas_on_fri) == {"christmas", "1", "c", dateFrom( 2015, 12, 27)}
    assert next_sunday(christmas_on_sat) == {"christmas", "1", "c", dateFrom( 2021, 12, 26)}
  end

  test "christmas is on Sunday" do
    friday = dateFrom 2016, 12, 23
    xmas = dateFrom 2016, 12, 25
    holyName = dateFrom 2017, 1, 1
    assert next_sunday(friday) == {"christmasDay", "1", "a", xmas}
    assert next_sunday(xmas) == {"holyName", "1", "a", holyName }
  end

  test "next_sunday returns epiphany" do
    assert next_sunday(dateFrom 2018,1,6)  == {"epiphany", "1", "b", dateFrom(2018, 1, 7)}
    assert next_sunday(dateFrom 2018,1,20) == {"epiphany", "3", "b", dateFrom(2018, 1, 21)}
    assert next_sunday(dateFrom 2018,2,3)  == {"epiphany", "8", "b", dateFrom(2018, 2, 4)}
    assert next_sunday(dateFrom 2018,2,10) == {"epiphany", "9", "b", dateFrom(2018, 2, 11)}
  end

  test "lityear returns sundays" do
    today       = dateFrom 2015,3,17
    next_sunday = dateFrom 2015,3,22
    last_sunday = dateFrom 2015,3,15
    refute( is_sunday?(today))
    assert( is_sunday?(next_sunday))
    assert( is_sunday?(last_sunday))
    assert( date_next_sunday(today) == next_sunday)
    assert( date_last_sunday(today) == last_sunday)
  end

  test "next_holy_day returns correct date" do
    assert next_holy_day(dateFrom 2016, 3, 6) == {stJoseph(2016), "stJoseph"} # leap yea
    assert next_holy_day(dateFrom 2018, 3, 6) == {stJoseph(2018), "stJoseph"}
    assert next_holy_day(dateFrom 2016, 1, 2) == {confessionOfStPeter(2016), "confessionOfStPeter"}
    assert next_holy_day(dateFrom 2017, 1, 2) == {confessionOfStPeter(2017), "confessionOfStPeter"}
    assert next_holy_day(dateFrom 2016, 9, 15) == {stMatthew(2016), "stMatthew"}
    assert next_holy_day(dateFrom 2017, 9, 15) == {stMatthew(2017), "stMatthew"}
    assert next_holy_day(dateFrom 2016, 12, 30) == {confessionOfStPeter(2017), "confessionOfStPeter"}
    assert next_holy_day(dateFrom 2017, 12, 30) == {confessionOfStPeter(2018), "confessionOfStPeter"}
  end

  test "next_holy_day returns next day when holy_day is on sunday" do
    assert stJoseph(2018) == dateFrom 2018, 3, 19
    assert stJoseph(2017) == dateFrom 2017, 3, 20 # on sunday
  end

  test "lityear gives correct advent dates" do
    year = 2015
    christmas_date = dateFrom year,12,25
    refute is_sunday?(christmas_date)
    assert advent(4, year) == christmas_date |> date_last_sunday
  end

  test "finding epiphany not on sunday" do
    epiphany1 = dateFrom 2015,1,11
    assert epiphany(0) == {:error, "There is no Epiphany before year 0."}
    assert epiphany(1, 2015) == epiphany1
  end

# from http://tlarsen2.tripod.com/thomaslarsen/easterdates.html
# 20th April 2014   10th April 2039    6th April 2064    3rd April 2089
#  5th April 2015    1st April 2040   29th March 2065   16th April 2090
# 27th March 2016   21st April 2041   11th April 2066    8th April 2091
# 16th April 2017    6th April 2042    3rd April 2067   30th March 2092
  test "finding Easter" do
    assert easter(2014) == dateFrom 2014, 4, 20
    assert easter(2015) == dateFrom 2015, 4,  5
    assert easter(2016) == dateFrom 2016, 3, 27
    assert easter(2017) == dateFrom 2017, 4, 16
    assert easter(2039) == dateFrom 2039, 4, 10
    assert easter(2040) == dateFrom 2040, 4,  1
    assert easter(2041) == dateFrom 2041, 4, 21
    assert easter(2042) == dateFrom 2042, 4,  6
    assert easter(2064) == dateFrom 2064, 4,  6
    assert easter(2065) == dateFrom 2065, 3, 29
    assert easter(2066) == dateFrom 2066, 4, 11
    assert easter(2067) == dateFrom 2067, 4,  3
    assert easter(2089) == dateFrom 2089, 4,  3
    assert easter(2090) == dateFrom 2090, 4, 16
    assert easter(2091) == dateFrom 2091, 4,  8
    assert easter(2092) == dateFrom 2092, 3, 30
  end

  test "finding ash wednesday" do
    assert ash_wednesday(2016) == dateFrom 2016, 2, 10
  end

  test "finding first sunday in lent" do
    assert lent(1, 2016) == dateFrom 2016, 2, 14
    assert lent(1) == lent(1, Timex.now.year)
  end

  test "finding pentecost" do
    assert pentecost(1, 2016) == dateFrom 2016, 5, 15
    assert pentecost(1) == pentecost(1, Timex.now.year)
  end

  test "finding the proper" do
    assert proper(29, 2016) == dateFrom 2016, 11, 20
    assert proper(2, 2016) == pentecost(1, 2016)
    assert proper(29) == proper(29, Timex.now.year)
  end

  test "finding thanksgiving" do
    assert thanksgiving(2012) == dateFrom 2012, 11, 22
    assert thanksgiving(2013) == dateFrom 2013, 11, 28
    assert thanksgiving(2014) == dateFrom 2014, 11, 27
    assert thanksgiving(2015) == dateFrom 2015, 11, 26
    assert thanksgiving(2016) == dateFrom 2016, 11, 24
    assert thanksgiving(2017) == dateFrom 2017, 11, 23
    assert thanksgiving(2022) == dateFrom 2022, 11, 24
    assert thanksgiving(2021) == dateFrom 2021, 11, 25
  end

  test "finding memorial day" do
    assert memorial(2016) == dateFrom 2016, 5, 30
    assert memorial(2017) == dateFrom 2017, 5, 29
    assert memorial(2018) == dateFrom 2018, 5, 28
    assert memorial(2019) == dateFrom 2019, 5, 27
    assert memorial(2020) == dateFrom 2020, 5, 25
    assert memorial(2021) == dateFrom 2021, 5, 31
    assert memorial(2025) == dateFrom 2025, 5, 26
    assert memorial(2026) == dateFrom 2026, 5, 25
  end

  test "epiphany_before_sunday" do
    assert epiphany_before_sunday(dateFrom 2017, 1, 7)
    assert epiphany_before_sunday(dateFrom 2017, 1, 6)
    refute epiphany_before_sunday(dateFrom 2017, 1, 8) # sunday
    refute epiphany_before_sunday(dateFrom 2018, 1, 7) # sunday, epiphany is on saturday
  end

  test "to_season returns proper season" do
    assert epiphany(2017) == dateFrom 2017, 1, 6
    assert epiphany(2017) |> to_season == {"epiphany", "0", "a", dateFrom( 2017, 1, 6)}
    assert dateFrom(2017, 1, 7) |> to_season == {"epiphany", "0", "a", dateFrom( 2017, 1, 7)}
  end
  
end
