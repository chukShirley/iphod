defmodule Iphod.LitYearTest do
  use ExUnit.Case, async: false
  use Plug.Test
  use Timex
  import Lityear
  alias Iphod.Lityear

  test "the truth" do
    assert (1 + 1) == 2
  end

    
  test "leap_year_correction?" do
    assert Timex.is_leap?(2016)
    refute leap_year_correction?(~D[2016-02-29])
    assert leap_year_correction?(~D[2016-03-01])
    refute leap_year_correction?(~D[2017-03-01])
  end

  test "days till sunday" do
    monday    = ~D[2016-03-07]
    tuesday   = ~D[2016-03-08]
    wednesday = ~D[2016-03-09]
    thursday  = ~D[2016-03-10]
    friday    = ~D[2016-03-11]
    saturday  = ~D[2016-03-12]
    sunday    = ~D[2016-03-13]
    assert days_till_sunday(monday) == 6
    assert days_till_sunday(tuesday) == 5
    assert days_till_sunday(wednesday) == 4
    assert days_till_sunday(thursday) == 3
    assert days_till_sunday(friday) == 2
    assert days_till_sunday(saturday) == 1
    assert days_till_sunday(sunday) == 7
  end

  test "translate_from_sunday - if date is a Sunday, should return date for Monday" do
    assert translate_from_sunday(~D[2017-03-19]) == ~D[2017-03-20]
  end

  test "translate_from_sunday - if date is not a Sunday, should return self" do
    assert translate_from_sunday(~D[2017-03-20]) == ~D[2017-03-20]
  end

  test "translate RLD from Sunday to Monday" do
    # St. Joseph falls on Sunday & should holy_day? should be false
    assert holy_day?(~D[2017-03-19]) == {false, ""}
    # the following day should show as St. Joseph
    assert holy_day?(~D[2017-03-20]) == {true, "stJoseph"}
  end

  test "checking The Transfiguration for 2017 (on a Sunday)" do
    assert holy_day?(~D[2017-08-06]) == {false, ""}
    assert holy_day?(~D[2017-08-07]) == {true, "transfiguration"}
  end

  test "The Presentation should not be translated" do
    day = ~D[2020-02-02]
    assert Timex.weekday(day) == 7 # it's a Sunday
    assert holy_day?(day) == {true, "presentation"}
  end


  test "lityear returns the proper liturgical year" do
    today       = ~D[2015-03-17]
    christmas   = ~D[2015-12-25]
    advent1     = ~D[2016-11-27]
    assert lityear(today) == 2015
    assert lityear(advent1) == 2017
    assert lityear(christmas) == 2016
  end

  test "abc() returns correct year letter" do
    today       = ~D[2015-03-17]
    last_year   = ~D[2014-03-17]
    christmas   = ~D[2015-12-25]
    advent1     = ~D[2016-11-27]
    assert abc(today) == "b"
    assert abc(christmas) == "c"
    assert abc(last_year) == "a"
    assert abc(advent1) == "a"
  end

  test "abc_atom() returns correct year atom" do
    today       = ~D[2015-03-17]
    last_year   = ~D[2014-03-17]
    christmas   = ~D[2015-12-25]
    advent1     = ~D[2016-11-27]
    assert abc_atom(today) == :b
    assert abc_atom(christmas) == :c
    assert abc_atom(last_year) == :a
    assert abc_atom(advent1) == :a
  end

  test "next_sunday returns easter" do
    date = ~D[2014-04-15]
    assert next_sunday(date) === {"easterDay", "1", "a", ~D[2014-04-20]}
  end
  test "next_sunday returns palm sunday" do
    tuesday =    ~D[2014-04-08]
    palmSunday = ~D[2014-04-13]
    assert next_sunday(tuesday) === {"palmSunday", "1", "a", palmSunday}
  end
  test "next_sunday returns lent" do
    tuesday = ~D[2016-02-09]
    sunday =  ~D[2016-02-14]
    assert next_sunday(tuesday) == {"lent", "1", "c", sunday}
  end
  test "next_sunday returns sundays in easter" do
    monday = ~D[2016-03-28]
    sunday = ~D[2016-04-03]
    assert next_sunday(monday) == {"easter", "2", "c", sunday}
  end
  test "next_sunday returns pentecost" do
    saturday = ~D[2016-05-14]
    sunday =   ~D[2016-05-15]
    assert next_sunday(saturday) == {"pentecost", "1", "c", sunday}
  end
  test "next_sunday returns proper" do
    friday = ~D[2016-05-27]
    sunday = ~D[2016-05-29]
    assert next_sunday(friday) == {"proper", "4", "c", sunday}
    wednesday = ~D[2016-11-16]
    sunday =    ~D[2016-11-20]
    assert next_sunday(wednesday) == {"proper", "29", "c", sunday}
  end
  test "next_sunday returns advent" do
    date = ~D[2016-11-25]
    assert next_sunday(date) == {"advent", "1", "a", ~D[2016-11-27]}
    date = ~D[2016-12-16]
    assert next_sunday(date) == {"advent", "4", "a", ~D[2016-12-18]}
  end

  test "next_sunday returns christmas 1" do
    christmas_on_mon = christmas(2017) # B
    christmas_on_tue = christmas(2018) # C
    christmas_on_wed = christmas(2013) # A
    christmas_on_thu = christmas(2014) # B
    christmas_on_fri = christmas(2015) # C
    christmas_on_sat = christmas(2021) # C
    assert next_sunday(christmas_on_mon) == {"christmas", "1", "b", ~D[2017-12-31]}
    assert next_sunday(christmas_on_tue) == {"christmas", "1", "c", ~D[2018-12-30]}
    assert next_sunday(christmas_on_wed) == {"christmas", "1", "a", ~D[2013-12-29]}
    assert next_sunday(christmas_on_thu) == {"christmas", "1", "b", ~D[2014-12-28]}
    assert next_sunday(christmas_on_fri) == {"christmas", "1", "c", ~D[2015-12-27]}
    assert next_sunday(christmas_on_sat) == {"christmas", "1", "c", ~D[2021-12-26]}
  end

  test "christmas is on Sunday" do
    friday =   ~D[2016-12-23]
    xmas =     ~D[2016-12-25]
    holyName = ~D[2017-01-01]
    assert next_sunday(friday) == {"christmasDay", "1", "a", xmas}
    assert next_sunday(xmas) == {"holyName", "1", "a", holyName }
  end

  test "next_sunday returns epiphany" do
    assert next_sunday(~D[2018-01-06])  == {"epiphany", "1", "b", ~D[2018-01-07]}
    assert next_sunday(~D[2018-01-20]) == {"epiphany", "3", "b", ~D[2018-01-21]}
    assert next_sunday(~D[2018-02-03])  == {"epiphany", "8", "b", ~D[2018-02-04]}
    assert next_sunday(~D[2018-02-10]) == {"epiphany", "9", "b", ~D[2018-02-11]}
  end

  test "epiphany_before_sunday?" do
    assert epiphany_before_sunday?(~D[2017-01-07])
    assert epiphany_before_sunday?(~D[2017-01-06])
    refute epiphany_before_sunday?(~D[2017-01-08]) # sunday
    refute epiphany_before_sunday?(~D[2018-01-07]) # sunday, epiphany is on saturday
    refute epiphany_before_sunday?(~D[2017-02-06])
  end

  test "mondays in epiphany" do
    day = ~D[2017-02-06]
    assert( to_season(day) == {"epiphany", "5", "a", day})
  end

  test "lityear returns sundays" do
    today       = ~D[2015-03-17]
    next_sunday = ~D[2015-03-22]
    last_sunday = ~D[2015-03-15]
    refute( is_sunday?(today))
    assert( is_sunday?(next_sunday))
    assert( is_sunday?(last_sunday))
    assert( date_next_sunday(today) == next_sunday)
    assert( date_last_sunday(today) == last_sunday)
  end

  test "next_holy_day returns correct date" do
    assert next_holy_day(~D[2016-03-06]) == {stJoseph(2016), "stJoseph"} # leap yea
    assert next_holy_day(~D[2018-03-06]) == {stJoseph(2018), "stJoseph"}
    assert next_holy_day(~D[2016-01-02]) == {confessionOfStPeter(2016), "confessionOfStPeter"}
    assert next_holy_day(~D[2017-01-02]) == {confessionOfStPeter(2017), "confessionOfStPeter"}
    assert next_holy_day(~D[2016-09-15]) == {stMatthew(2016), "stMatthew"}
    assert next_holy_day(~D[2017-09-15]) == {stMatthew(2017), "stMatthew"}
    assert next_holy_day(~D[2016-12-30]) == {confessionOfStPeter(2017), "confessionOfStPeter"}
    assert next_holy_day(~D[2017-12-30]) == {confessionOfStPeter(2018), "confessionOfStPeter"}

    assert next_holy_day(~D[2017-01-18]) == {confessionOfStPeter(2017), "confessionOfStPeter"}
  end

  test "Transfiguration on Sunday gets moved to Monday" do
    assert transfiguration(2017) == ~D[2017-08-07]
    assert next_holy_day(~D[2017-08-07]) == {transfiguration(2017), "transfiguration"}
  end

  test "next_holy_day returns next day when holy_day is on sunday" do
    assert stJoseph(2018) == ~D[2018-03-19]
    assert stJoseph(2017) == ~D[2017-03-20] # on sunday
  end

  test "lityear gives correct advent dates" do
    christmas_date = ~D[2015-12-25]
    refute is_sunday?(christmas_date)
    assert advent(4, 2015) == christmas_date |> date_last_sunday
  end

  test "finding epiphany not on sunday" do
    epiphany1 = ~D[2015-01-11]
    assert epiphany(0) == {:error, "There is no Epiphany before year 0."}
    assert epiphany(1, 2015) == epiphany1
  end

# from http://tlarsen2.tripod.com/thomaslarsen/easterdates.html
# 20th April 2014   10th April 2039    6th April 2064    3rd April 2089
#  5th April 2015    1st April 2040   29th March 2065   16th April 2090
# 27th March 2016   21st April 2041   11th April 2066    8th April 2091
# 16th April 2017    6th April 2042    3rd April 2067   30th March 2092
  test "finding Easter" do
    assert easter(2014) == ~D[2014-04-20]
    assert easter(2015) == ~D[2015-04-05]
    assert easter(2016) == ~D[2016-03-27]
    assert easter(2017) == ~D[2017-04-16]
    assert easter(2039) == ~D[2039-04-10]
    assert easter(2040) == ~D[2040-04-01]
    assert easter(2041) == ~D[2041-04-21]
    assert easter(2042) == ~D[2042-04-06]
    assert easter(2064) == ~D[2064-04-06]
    assert easter(2065) == ~D[2065-03-29]
    assert easter(2066) == ~D[2066-04-11]
    assert easter(2067) == ~D[2067-04-03]
    assert easter(2089) == ~D[2089-04-03]
    assert easter(2090) == ~D[2090-04-16]
    assert easter(2091) == ~D[2091-04-08]
    assert easter(2092) == ~D[2092-03-30]
  end

  test "correct Sunday in Lent" do
    assert to_season(~D[2017-03-06]) == {"lent", "1", "a", ~D[2017-03-06]}
  end

  test "correct Sunday in Epiphany" do
    assert to_season(~D[2017-01-03]) == {"christmas", "2", "a", ~D[2017-01-03]}
    assert to_season(~D[2017-01-07]) == {"epiphany", "0", "a", ~D[2017-01-07]}
    assert to_season(~D[2017-01-08]) == {"epiphany", "1", "a", ~D[2017-01-08]}
  end

  test "finding ash wednesday" do
    assert ash_wednesday(2016) == ~D[2016-02-10]
    assert ash_wednesday(~D[2017-02-02]) == ~D[2017-03-01]
  end

  test "to_season should return season of lent on Ash Wednesday" do
    assert to_season(~D[2017-03-01]) == {"ashWednesday", "1", "a", ~D[2017-03-01]}
  end

  test "to_season should return season of ascension on Ascension Day" do
    assert to_season(~D[2017-05-25]) == {"ascension", "1", "a", ~D[2017-05-25]}
  end

  test "right after ash wednesday" do
    # returns true if Wed - Sat following Ash Wednesday
    assert right_after_ash_wednesday?(~D[2017-03-01])
    assert right_after_ash_wednesday?(~D[2017-03-02])
    assert right_after_ash_wednesday?(~D[2017-03-03])
    assert right_after_ash_wednesday?(~D[2017-03-04])
    refute right_after_ash_wednesday?(~D[2017-02-28])
    refute right_after_ash_wednesday?(~D[2017-03-05])
  end

  test "to_season should return holyWeek 1 on Monday of HolyWeek" do
    assert to_season(~D[2017-04-10]) == {"holyWeek", "1", "a", ~D[2017-04-10]}
  end

  test "to_season should return holyWeek 2 on Tuesday of HolyWeek" do
    assert to_season(~D[2017-04-11]) == {"holyWeek", "2", "a", ~D[2017-04-11]}
  end

  test "to_season should return holyWeek 3 on Wednesday of Holy Week" do
    assert to_season(~D[2017-04-12]) == {"holyWeek", "3", "a", ~D[2017-04-12]}
  end

  test "to_season should return holyWeek 4 on Maunday THursday" do
    assert to_season(~D[2017-04-13]) == {"holyWeek", "4", "a", ~D[2017-04-13]}
  end

  test "to_season should return goodFriday 1 on Good Friday" do
    assert to_season(~D[2017-04-14]) == {"goodFriday", "1", "a", ~D[2017-04-14]}
  end

  test "to_season should return holyWeek 6 on Holy Saturday" do
    assert to_season(~D[2017-04-15]) == {"holyWeek", "6", "a", ~D[2017-04-15]}
  end

  test "to_season should return easterWeek 1 on Monday of Easter Week" do
    assert to_season(~D[2017-04-17]) == {"easterWeek", "1", "a", ~D[2017-04-17]}
  end

  test "to_season should return easterWeek 2 on Tuesday of Easter Week" do
    assert to_season(~D[2017-04-18]) == {"easterWeek", "2", "a", ~D[2017-04-18]}
  end

  test "to_season should return easterWeek 3 on Wednesday of Easter Week" do
    assert to_season(~D[2017-04-19]) == {"easterWeek", "3", "a", ~D[2017-04-19]}
  end

  test "to_season should return easterWeek 4 on Thursday of Easter Week" do
    assert to_season(~D[2017-04-20]) == {"easterWeek", "4", "a", ~D[2017-04-20]}
  end

  test "to_season should return easterWeek 5 on Friday of Easter Week" do
    assert to_season(~D[2017-04-21]) == {"easterWeek", "5", "a", ~D[2017-04-21]}
  end

  test "to_season should return easterWeek 6 on Saturday of Easter Week" do
    assert to_season(~D[2017-04-22]) == {"easterWeek", "6", "a", ~D[2017-04-22]}
  end

  test "right after ascension" do
    assert right_after_ascension?(~D[2017-05-25])
    assert right_after_ascension?(~D[2017-05-26])
    assert right_after_ascension?(~D[2017-05-27])
    refute right_after_ascension?(~D[2017-05-24])
    refute right_after_ascension?(~D[2017-05-28])
  end

  test "finding first sunday in lent" do
    assert lent(1, 2016) == ~D[2016-02-14]
    assert lent(1) == lent(1, Timex.now.year)
  end

  test "finding pentecost" do
    assert pentecost(1, 2016) == ~D[2016-05-15]
    assert pentecost(1) == pentecost(1, Timex.now.year)
  end

  test "finding the proper" do
    assert proper(29, 2016) == ~D[2016-11-20]
    assert proper(2, 2016) == pentecost(1, 2016)
    assert proper(29) == proper(29, Timex.now.year)
  end

  test "finding thanksgiving" do
    assert thanksgiving(2012) == ~D[2012-11-22]
    assert thanksgiving(2013) == ~D[2013-11-28]
    assert thanksgiving(2014) == ~D[2014-11-27]
    assert thanksgiving(2015) == ~D[2015-11-26]
    assert thanksgiving(2016) == ~D[2016-11-24]
    assert thanksgiving(2017) == ~D[2017-11-23]
    assert thanksgiving(2022) == ~D[2022-11-24]
    assert thanksgiving(2021) == ~D[2021-11-25]
  end

  test "finding memorial day" do
    assert memorial(2016) == ~D[2016-05-30]
    assert memorial(2017) == ~D[2017-05-29]
    assert memorial(2018) == ~D[2018-05-28]
    assert memorial(2019) == ~D[2019-05-27]
    assert memorial(2020) == ~D[2020-05-25]
    assert memorial(2021) == ~D[2021-05-31]
    assert memorial(2025) == ~D[2025-05-26]
    assert memorial(2026) == ~D[2026-05-25]
  end

  test "to_season returns proper season" do
    assert epiphany(2017) == ~D[2017-01-06]
    assert epiphany(2017) |> to_season == {"epiphany", "0", "a", ~D[2017-01-06]}
    assert ~D[2017-01-07] |> to_season == {"epiphany", "0", "a", ~D[2017-01-07]}
  end
  
end
