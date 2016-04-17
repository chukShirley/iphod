require IEx
defmodule  Lityear do
  use Timex

  @sunday 7
  @thursday 4
  @tz "America/Los_Angeles"

  def bad_arg(), do: bad_arg('')
  def bad_arg(s), do: "Eh? " <> s
  def is_date(d), do: is_map(d) and d.__struct__ == Timex.DateTime
  def date_shift(d, arg), do: Timex.shift(d,arg) |> Timex.to_date
  def lityear(), do: lityear Date.now(@tz)
  def lityear(d) do
    if Timex.day(d) >= Timex.day(advent(1, d.year)) do
      d.year + 1
    else
      d.year
    end
  end
  def abc(d), do: {"c", "a", "b"} |> elem(d|>lityear|>rem(3))
  def abc_atom(d), do: {:c, :a, :b} |> elem(d|>lityear|>rem(3))
  def is_sunday?(), do: Date.now(@tz) |> Timex.weekday == @sunday
  def is_sunday?(d), do: Timex.weekday(d) == @sunday
  def days_till_sunday(date) do
    days_till_sunday = %{1 => 6, 2 => 5, 3 => 4, 4 => 3, 5 => 2, 6 => 1, 7 => 7}
    days_till_sunday[Timex.weekday(date)]
  end
  def date_next_sunday(),   do: Date.now(@tz) |> date_next_sunday
  def date_next_sunday(d),  do: date_shift(d, days: days_till_sunday(d))
  def date_last_sunday(),   do: date_last_sunday(Date.now(@tz))
  def date_last_sunday(d),  do: date_shift(d, days: -Timex.weekday(d))
  def last_sunday(),        do: date_last_sunday              |> to_season
  def last_sunday(d),       do: date_last_sunday(d)           |> to_season
  def next_sunday(),        do: date_next_sunday(Date.now(@tz))  |> to_season
  def next_sunday(d),       do: date_next_sunday(d)           |> to_season
  def from_now(), do: to_season Date.now(@tz)
  def to_season(day) do
    sunday = if day |> is_sunday?, do: day, else: day |> date_next_sunday
    y = lityear sunday
    yrABC = abc sunday
    # to the next guy...
    # when comparing dates as `sunday > advent(1, sunday.year)`
    # read as `does sunday come before advent(1, sunday.year)?`
    # this keeps tripping me up
    till_advent = Timex.diff(sunday, advent(1, sunday.year), :weeks)
    till_advent = if sunday > advent(1, sunday.year), do: till_advent, else: -till_advent
    from_christmas = Timex.diff(sunday, christmas(1, y), :weeks)
#    from_easter = Timex.diff(easter_day(y), sunday, :days) |> div(7) |> abs
    from_easter = Timex.diff(easter_day(y), sunday, :weeks) |> abs
    from_easter = if easter_day(y) > sunday, do: from_easter, else: -from_easter
    till_epiphany = Timex.diff(sunday, epiphany(y), :days)
    from_epiphany = Timex.diff(epiphany(1, y), sunday, :weeks)
    cond do
      # to whom it may concern...
      # changes the order of these conditions at your paril
      day == epiphany(y)   -> {"theEpiphany", "1", yrABC, day}
      day == christmas(y)  -> {"christmasDay", "1", yrABC, day}
      till_epiphany in 1..4   -> {"christmas", "2", yrABC, day}
      till_epiphany == 5      -> {"holyName", "1", yrABC, day}
      till_epiphany in 6..11  -> {"christmas", "1", yrABC, day}
      from_easter in -2..-6   -> {"lent", to_string(7 + from_easter), yrABC, day}
      from_easter == -1       -> {"palmSunday", "1", yrABC, day}
      from_easter == -7       -> {"epiphany", "9", yrABC, day}
      from_easter == -8       -> {"epiphany", "8", yrABC, day}
      from_easter == 0        -> {"easterDay", "1", yrABC, day}
      from_easter in 0..6     -> {"easter", to_string(1 + from_easter), yrABC, day}
      from_easter == 7        -> {"pentecost", "1", yrABC, day}
      from_easter == 8        -> {"trinity", "1", yrABC, day}
      till_advent in 1..27    -> {"proper", to_string(30 - till_advent), yrABC, day}
      till_advent in 0..-3    -> {"advent", to_string(1 - till_advent), yrABC, day}
      from_christmas in 0..1  -> {"christmas", to_string(from_christmas + 1), day}
      from_epiphany in 0..8   -> {"epiphany", to_string(from_epiphany + 1), yrABC, day}
      true -> {"unknown", "unknown", :unknown, day}
    end
   end

  def advent(),         do: advent(1)
  def advent(n),        do: christmas    |> date_last_sunday |> date_shift( weeks: n-4)
  def advent(n, y),     do: christmas(y) |> date_last_sunday |> date_shift( weeks: n-4)

  def christmas(),      do: Timex.date {Date.now(@tz).year, 12, 25}
  def christmas(n) when n < 1, do: {:error, "There is no Christmas before year 0"}
  def christmas(n) when n > 2, do: Timex.date {n, 12, 25} # presume n is a year
  def christmas(n) do # n is 1 or 2, presume sunday after christmas
    christmas |> date_next_sunday |> date_shift( weeks: n - 1)
  end
  def christmas(n,y),   do: christmas(y) |> date_shift( weeks: n)
  
  def epiphany,   do: Timex.date({lityear, 1, 6})
  def epiphany(n) when n < 1,         do: {:error, "There is no Epiphany before year 0."}
  def epiphany(n) when n in (1..9),   do: epiphany n, Date.now(@tz).year
  def epiphany(n) when is_integer(n), do: Timex.date {{n, 1, 6},{0,0,0}}
  def epiphany(d),                    do: Timex.date {{d.year, 1, 6},{0,0,0}}
  def epiphany(n, yr) do
    Timex.date( {{yr, 1, 6}, {0,0,0}}) |> date_next_sunday |> date_shift( weeks: n - 1)
  end

  def epiphany_last(),      do: date_last_sunday ash_wednesday
  def epiphany_last(yr),    do: date_last_sunday ash_wednesday(yr)
    
  def ash_wednesday(),                      do: date_shift(easter, days: -46)
  def ash_wednesday(y) when is_integer(y),  do: date_shift(_easter(y), days: -46)
  def ash_wednesday(d),   do: date_shift(_easter(d.year), days: -46)
  def lent(),             do: ash_wednesday |> date_next_sunday
  def lent(n) when n < 6, do: lent(n, Date.now(@tz).year)
  def lent(y),            do: ash_wednesday(y) |> date_next_sunday
  def lent(n, yr),        do: lent(yr) |> date_shift( weeks: (n-1))

  def palm_sunday(),        do: easter |> date_shift( weeks: -1)
  def palm_sunday(year),    do: easter(year) |> date_shift( weeks: -1)

  def easter(),                 do: lityear(Date.now(@tz)) |> _easter
  def easter(n) when n >= 30,   do: _easter(n)
  def easter(n) when n in 1..7, do: easter |> date_shift(weeks: (n - 1))
  def easter(_n),               do: {:error, "Eh? There is no Easter before the Resurrection!"}
  def easter_day(year),         do: _easter(year)
  def easter(week, year),       do: date_shift(_easter(year), weeks: (week - 1))
  @doc """
  algorithm from `http://en.wikipedia.org/wiki/Computus#cite_note-otheralgs-47
  """
  def _easter(year) do
    a = rem(year, 19)
    b = div(year, 100)
    c = rem(year, 100)
    d = div(b, 4)
    e = rem(b, 4)
    f = div((b+8), 25)
    g = div((b - f + 1), 3)
    h = rem(19*a + b - d - g + 15, 30)
    i = div(c, 4)
    k = rem(c, 4)
    l = rem(32 + 2*e + 2*i - h - k, 7)
    m = div(a + 11*h + 22*l, 451)
    month = div(h + l - 7*m + 114, 31)
    day = rem(h + l - 7*m + 114, 31) + 1
    Timex.date({year, month, day})
  end
  def pentecost(),    do: pentecost(1, lityear)
  def pentecost(n),   do: pentecost(n, lityear)
  def pentecost(n,y), do: easter(n+7, y)
  def trinity(),      do: pentecost(2, lityear)
  def trinity(y),     do: pentecost(2, y)
  def proper(n) when n < 30,            do: proper(n, lityear)
  def proper(d) do
    29 - Timex.diff(d, Lityear.advent(0, d.year), :weeks)
  end
  def proper(n, yr) when is_integer(n), do: advent(n - 29, yr)

  def sunday_to_date('easter', week, year),     do: easter(week, year)
  def sunday_to_date('pentecost', week, year),  do: pentecost(week, year)
  def sunday_to_date('trinity', _week, year),   do: pentecost(2, year)
  def sunday_to_date('proper', week, year),     do: proper(week, year)
  def sunday_to_date('advent', week, year),     do: advent(week, year)
  def sunday_to_date('christmas', week, year),  do: christmas(week, year)
  def sunday_to_date('epiphany', week, year),   do: epiphany(week, year)
  def sunday_to_date('lent', week, year),       do: epiphany(week, year)

  def next_holy_day(date) do
    holy_days =
      %{  18  => "confessionOfStPeter",
          383 => "confessionOfStPeter", # for dates at end of dec
          25  => "conversionOfStPaul",
          55  => "stMatthias",
          79  => "stJoseph",
          85  => "annunciation",
          116 => "stMark",
          122 => "stsPhilipAndJames",
          152 => "visitation",
          163 => "stBarnabas",
          176 => "nativityOfJohnTheBaptist",
          181 => "stPeterAndPaul",
          183 => "dominion",
          186 => "independence",
          204 => "stMaryMagdalene",
          207 => "stJames",
          219 => "transfiguration",
          228 => "bvm",
          237 => "stBartholomew",
          258 => "holyCross",
          265 => "stMatthew",
          273 => "michaelAllAngels",
          292 => "stLuke",
          297 => "stJames",
          302 => "stsSimonAndJude",
          316 => "remembrance",
          334 => "stAndrew",
          356 => "stThomas",
          361 => "stStephen",
          362 => "stJohn",
          363 => "holyInnocents"
      }
      day = [ 0, # zero indexed
        18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,25,25,25,25,25,25,25,55,55,55,55,55,55,  # jan
        55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,79,79,79,79,           # feb
        79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,79,85,85,85,85,85,85,116,116,116,116,116,116,  # mar
        116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,116,122,122,122,122,122,     # apr
        122,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152,152, # may
        163,163,163,163,163,163,163,163,163,163,163,176,176,176,176,176,176,176,176,176,176,176,176,176,181,181,181,181,181,183,     # jun
        183,186,186,186,204,204,204,204,204,204,204,204,204,204,204,204,204,204,204,204,204,204,207,207,207,219,219,219,219,219,219, # jul
        219,219,219,219,219,219,228,228,228,228,228,228,228,228,228,237,237,237,237,237,237,237,237,237,258,258,258,258,258,258,258, # aug
        258,258,258,258,258,258,258,258,258,258,258,258,258,258,265,265,265,265,265,265,265,273,273,273,273,273,273,273,273,292,     # sep
        292,292,292,292,292,292,292,292,292,292,292,292,292,292,292,292,292,292,297,297,297,297,297,302,302,302,302,302,316,316,316, # oct
        316,316,316,316,316,316,316,316,316,316,316,334,334,334,334,334,334,334,334,334,334,334,334,334,334,334,334,334,334,334,     # nov
        356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,356,362,362,362,362,362,363,383,383,383,383  # dec
      ]
      |> Enum.at( date |> Timex.day)
      n = cond do
            date |> Timex.compare(Timex.date {date.year, 2, 28}) < 0 -> 1
            date |> Timex.day <= 362 && not( date |> Timex.is_leap?) -> 2
            date |> Timex.day > 362 && not( date |> Timex.is_leap?) -> 1
            date |> Timex.day <= 362 -> 1
            date |> Timex.is_leap? -> 0
            true -> 1
      end
      date = Timex.date({date.year, 1, 1}) |> date_shift(days: day - n)
      {date, holy_days[day]}
  end

  def namedDayDate("palmSundayPalms", _wk), do: palm_sunday
  def namedDayDate("palmSunday", _wk), do: palm_sunday
  def namedDayDate("holyWeek", wk) when wk |> is_bitstring, do: namedDayDate("holyWeek", wk |> String.to_integer)
  def namedDayDate("holyWeek", wk), do: palm_sunday |> date_shift(days: wk)
  def namedDayDate("easterDayVigil", _wk), do: easter |> date_shift(days: -1)
#  def namedDayDate("easterDay", wk) when wk |> is_bitstring, do: namedDayDate("easterDay", wk |> String.to_integer) 
  def namedDayDate("easterDay", _wk), do: easter  
  def namedDayDate("easterWeek", wk) when wk |> is_bitstring, do: namedDayDate("easterWeek", wk |> String.to_integer) 
  def namedDayDate("easterWeek", wk), do: easter |> date_shift(days: wk)  

  def stAndrew(), do: stAndrew(Date.now(@tz).year)
  def stAndrew(year), do: Timex.date {year, 11, 30}
  def stThomas(), do: stThomas(Date.now(@tz).year)
  def stThomas(year), do: Timex.date {year, 12, 21 }
  def stStephen(), do: stStephen(Date.now(@tz).year)
  def stStephen(year), do: Timex.date {year, 12, 26 }
  def stJohn(), do: stJohn(Date.now(@tz).year)
  def stJohn(year), do: Timex.date {year, 12, 27 }
  def holyInnocents(), do: holyInnocents(Date.now(@tz).year)
  def holyInnocents(year), do: Timex.date {year, 12, 28 }
  def confessionOfStPeter(), do: confessionOfStPeter(Date.now(@tz).year)
  def confessionOfStPeter(year), do: Timex.date {year, 1, 18 }
  def conversionOfStPaul(), do: conversionOfStPaul(Date.now(@tz).year)
  def conversionOfStPaul(year), do: Timex.date {year, 1, 25 }
  def stMatthias(), do: stMatthias(Date.now(@tz).year)
  def stMatthias(year), do: Timex.date {year, 2, 24 }
  def stJoseph(), do: stJoseph(Date.now(@tz).year)
  def stJoseph(year), do: Timex.date {year, 3, 19 }
  def annunciation(), do: annunciation(Date.now(@tz).year)
  def annunciation(year), do: Timex.date {year, 3, 25 }
  def stMark(), do: stMark(Date.now(@tz).year)
  def stMark(year), do: Timex.date {year, 4, 25 }
  def stsPhilipAndJames(), do: stsPhilipAndJames(Date.now(@tz).year)
  def stsPhilipAndJames(year), do: Timex.date {year, 5, 1 }
  def visitation(), do: visitation(Date.now(@tz).year)
  def visitation(year), do: Timex.date {year, 5, 31 }
  def stBarnabas(), do: stBarnabas(Date.now(@tz).year)
  def stBarnabas(year), do: Timex.date {year, 6, 11 }
  def nativityOfJohnTheBaptist(), do: nativityOfJohnTheBaptist(Date.now(@tz).year)
  def nativityOfJohnTheBaptist(year), do: Timex.date {year, 6, 24 }
  def stPeterAndPaul(), do: stPeterAndPaul(Date.now(@tz).year)
  def stPeterAndPaul(year), do: Timex.date {year, 6, 29 }
  def dominion(), do: dominion(Date.now(@tz).year)
  def dominion(year), do: Timex.date {year, 7, 1 }
  def independence(), do: independence(Date.now(@tz).year)
  def independence(year), do: Timex.date {year, 7, 4 }
  def stMaryMagdalene(), do: stMaryMagdalene(Date.now(@tz).year)
  def stMaryMagdalene(year), do: Timex.date {year, 7, 22 }
  def stJames(), do: stJames(Date.now(@tz).year)
  def stJames(year), do: Timex.date {year, 7, 25 }
  def transfiguration(), do: transfiguration(Date.now(@tz).year)
  def transfiguration(year), do: Timex.date {year, 8, 6 }
  def bvm(), do: bvm(Date.now(@tz).year)
  def bvm(year), do: Timex.date {year, 8, 15 }
  def stBartholomew(), do: stBartholomew(Date.now(@tz).year)
  def stBartholomew(year), do: Timex.date {year, 8, 24 }
  def holyCross(), do: holyCross(Date.now(@tz).year)
  def holyCross(year), do: Timex.date {year, 9, 14}
  def stMatthew(), do: stMatthew(Date.now(@tz).year)
  def stMatthew(year), do: Timex.date {year, 9, 21 }
  def michaelAllAngels(), do: michaelAllAngels(Date.now(@tz).year)
  def michaelAllAngels(year), do: Timex.date {year, 9, 29 }
  def stLuke(year), do: Timex.date {year, 10, 18 }
  def stLuke(), do: stLuke(Date.now(@tz).year)
  def stJamesOfJerusalem(year), do: Timex.date {year, 10, 23 }
  def stJamesOfJerusalem(), do: stJames(Date.now(@tz).year)
  def stsSimonAndJude(), do: stsSimonAndJude(Date.now(@tz).year)
  def stsSimonAndJude(year), do: Timex.date {year, 10, 28 }
  def remembrance(), do: remembrance(Date.now(@tz).year)
  def remembrance(year), do: Timex.date {year, 11, 11 }

  # thanksgiving = 4th thursday of november
  def thanksgiving(), do: thanksgiving(Date.now(@tz).year)
  def thanksgiving(n) do
    tgd = %{1 => 25, 2 => 24, 3 => 23, 4 => 22, 5 => 28, 6 => 27, 7 => 26}
    dow = Timex.date( {n, 11, 1}) |> Timex.weekday
    Timex.date {n, 11, tgd[dow]}
  end

  def memorial(), do: memorial(Date.now(@tz).year)
  def memorial(n) do
    md = %{1 => 28, 2 => 27, 3 => 26, 4 => 25, 5 => 31, 6 => 30, 7 => 29}
    dow = Timex.date({n, 5, 28}) |> Timex.weekday
    Timex.date {n, 5, md[dow]}
  end

end