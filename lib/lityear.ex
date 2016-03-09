require IEx
defmodule  Lityear do
  use Timex

  @sunday 7
  @thursday 4

  def bad_arg(), do: bad_arg('')
  def bad_arg(s), do: "Eh? " <> s
  def is_date(d), do: is_map(d) and d.__struct__ == Timex.DateTime
  def lityear(), do: lityear Date.local
  def lityear(d) do
    if Date.diff(advent(1, d.year), d, :days) >= 0 do
      d.year + 1
    else
      d.year
    end
  end
  def abc(d), do: {"C", "A", "B"} |> elem(d|>lityear|>rem(3))
  def abc_atom(d), do: {:c, :a, :b} |> elem(d|>lityear|>rem(3))
  def is_sunday?(), do: Date.local |> Date.weekday == @sunday
  def is_sunday?(d), do: Date.weekday(d) == @sunday
  def days_till_sunday(date) do
    days_till_sunday = %{1 => 6, 2 => 5, 3 => 4, 4 => 3, 5 => 2, 6 => 1, 7 => 7}
    days_till_sunday[Date.weekday(date)]
  end
  def date_next_sunday(),   do: Date.local |> date_next_sunday
  def date_next_sunday(d),  do: Date.shift(d, days: days_till_sunday(d))
  def date_last_sunday(),   do: date_last_sunday(Date.local)
  def date_last_sunday(d),  do: Date.shift(d, days: -Date.weekday(d))
  def last_sunday(),        do: readings date_last_sunday
  def last_sunday(d),       do: readings date_last_sunday(d)
  def next_sunday(),        do: readings date_next_sunday(Date.local)
  def next_sunday(d),       do: readings date_next_sunday(d)
  def readings(sunday) do
    IO.puts "READINGS: #{inspect sunday}"
    y = lityear sunday
    yrABC = abc_atom sunday
    till_advent = Date.diff(sunday, advent(1, sunday.year), :weeks)
    from_christmas = Date.diff(sunday, christmas(1, y), :weeks)
    from_easter = Date.diff(easter_day(y), sunday, :weeks)
    till_epiphany = Date.diff(sunday, epiphany(y), :days)
    from_epiphany = Date.diff(epiphany(1, y), sunday, :weeks)
    cond do
      # to whom it may concern...
      # changes the order of these conditions at your paril
      sunday == epiphany(y)   -> {"theEpiphany", "1", yrABC, sunday}
      sunday == christmas(y)  -> {"christmasDay", "1", yrABC, sunday}
      till_epiphany in 1..4   -> {"christmas", "2", yrABC, sunday}
      till_epiphany == 5      -> {"holyName", "1", yrABC, sunday}
      till_epiphany in 6..11  -> {"christmas", "1", yrABC, sunday}
      from_easter == 0        -> {"easterDay", "1", yrABC, sunday}
      from_easter == -1       -> {"palmSunday", "1", yrABC, sunday}
      from_easter in -2..-6   -> {"lent", to_string(7 + from_easter), yrABC, sunday}
      from_easter == -7       -> {"epiphany", "9", yrABC, sunday}
      from_easter == -8       -> {"epiphany", "8", yrABC, sunday}
      from_easter in 0..6     -> {"easter", to_string(1 + from_easter), yrABC, sunday}
      from_easter in 7..8     -> {"proper", to_string(from_easter - 6), yrABC, sunday}
      till_advent in 1..27    -> {"proper", to_string(30 - till_advent), yrABC, sunday}
      till_advent in 0..-3    -> {"advent", to_string(1 - till_advent), yrABC, sunday}
      from_christmas in 0..1  -> {"christmas", to_string(from_christmas + 1), sunday}
      from_epiphany in 0..8   -> {"epiphany", to_string(from_epiphany + 1), yrABC, sunday}
      true -> {"unknown", "unknown", :unknown, sunday}
    end
   end

  def advent(),         do: advent(1)
  def advent(n),        do: christmas    |> date_last_sunday |> Date.shift( weeks: n-4)
  def advent(n, y),     do: christmas(y) |> date_last_sunday |> Date.shift( weeks: n-4)

  def christmas(),      do: Date.from {Date.local.year, 12, 25}
  def christmas(n) when n < 1, do: {:error, "There is no Christmas before year 0"}
  def christmas(n) when n > 2, do: Date.from {n, 12, 25} # presume n is a year
  def christmas(n) do # n is 1 or 2, presume sunday after christmas
    christmas |> date_next_sunday |> Date.shift( weeks: n - 1)
  end
  def christmas(n,y),   do: christmas(y) |> Date.shift( weeks: n)
  
  def epiphany,   do: Date.from({lityear, 1, 6})
  def epiphany(n) when n < 1,         do: {:error, "There is no Epiphany before year 0."}
  def epiphany(n) when n in (1..9),   do: epiphany n, Date.local.year
  def epiphany(n) when is_integer(n), do: Date.from {{n, 1, 6},{0,0,0}}
  def epiphany(d),                    do: Date.from {{d.year, 1, 6},{0,0,0}}
  def epiphany(n, yr) do
    Date.from( {{yr, 1, 6}, {0,0,0}}) |> date_next_sunday |> Date.shift( weeks: n - 1)
  end

  def epiphany_last(),      do: date_last_sunday ash_wednesday
  def epiphany_last(yr),    do: date_last_sunday ash_wednesday(yr)
    
  def ash_wednesday(),                      do: Date.shift(easter, days: -46)
  def ash_wednesday(y) when is_integer(y),  do: Date.shift(_easter(y), days: -46)
  def ash_wednesday(d),   do: Date.shift(_easter(d.year), days: -46)
  def lent(),             do: ash_wednesday |> date_next_sunday
  def lent(n) when n < 6, do: lent(n, Date.local.year)
  def lent(y),            do: ash_wednesday(y) |> date_next_sunday
  def lent(n, yr),        do: lent(yr) |> Date.shift( weeks: (n-1))

  def palm_sunday(),        do: easter |> Date.shift( weeks: -1)
  def palm_sunday(year),    do: easter(year) |> Date.shift( weeks: -1)

  def easter(),                 do: lityear(Date.local) |> _easter
  def easter(n) when n >= 30,   do: _easter(n)
  def easter(n) when n in 1..7, do: easter |> Date.shift(weeks: (n - 1))
  def easter(n),                do: {:error, "Eh? There is no Easter before the Resurrection!"}
  def easter_day(year),         do: _easter(year)
  def easter(week, year),       do: Date.shift(_easter(year), weeks: (week - 1))
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
    Date.from({year, month, day})
  end
  def pentecost(),    do: pentecost(1, lityear)
  def pentecost(n),   do: pentecost(n, lityear)
  def pentecost(n,y), do: easter(n+7, y)
  def trinity(),      do: pentecost(2, lityear)
  def trinity(y),     do: pentecost(2, y)
  def proper(n) when n < 30,            do: proper(n, lityear)
  def proper(n, yr) when is_integer(n), do: advent(n - 29, yr)
  def proper(d) do
    29 - Date.diff(d, Lityear.advent(0, d.year), :weeks)
  end

  def sunday_to_date('easter', week, year),     do: easter(week, year)
  def sunday_to_date('pentecost', week, year),  do: pentecost(week, year)
  def sunday_to_date('trinity', week, year),    do: pentecost(2, year)
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
      |> Enum.at( date |> Date.day)
      n = cond do
            date |> Date.compare(Date.from {date.year, 2, 28}) < 0 -> 1
            date |> Date.day <= 362 && not( date |> Date.is_leap?) -> 2
            date |> Date.day > 362 && not( date |> Date.is_leap?) -> 1
            date |> Date.day <= 362 -> 1
            date |> Date.is_leap? -> 0
            true -> 1
      end
      date = Date.from({date.year, 1, 1}) |> Date.shift(days: day - n)
      {date, holy_days[day]}
  end

  def stAndrew(), do: stAndrew(Date.local.year)
  def stAndrew(year), do: Date.from {year, 11, 30}
  def stThomas(), do: stThomas(Date.local.year)
  def stThomas(year), do: Date.from {year, 12, 21 }
  def stStephen(), do: stStephen(Date.local.year)
  def stStephen(year), do: Date.from {year, 12, 26 }
  def stJohn(), do: stJohn(Date.local.year)
  def stJohn(year), do: Date.from {year, 12, 27 }
  def holyInnocents(), do: holyInnocents(Date.local.year)
  def holyInnocents(year), do: Date.from {year, 12, 28 }
  def confessionOfStPeter(), do: confessionOfStPeter(Date.local.year)
  def confessionOfStPeter(year), do: Date.from {year, 1, 18 }
  def conversionOfStPaul(), do: conversionOfStPaul(Date.local.year)
  def conversionOfStPaul(year), do: Date.from {year, 1, 25 }
  def stMatthias(), do: stMatthias(Date.local.year)
  def stMatthias(year), do: Date.from {year, 2, 24 }
  def stJoseph(), do: stJoseph(Date.local.year)
  def stJoseph(year), do: Date.from {year, 3, 19 }
  def annunciation(), do: annunciation(Date.local.year)
  def annunciation(year), do: Date.from {year, 3, 25 }
  def stMark(), do: stMark(Date.local.year)
  def stMark(year), do: Date.from {year, 4, 25 }
  def stsPhilipAndJames(), do: stsPhilipAndJames(Date.local.year)
  def stsPhilipAndJames(year), do: Date.from {year, 5, 1 }
  def visitation(), do: visitation(Date.local.year)
  def visitation(year), do: Date.from {year, 5, 31 }
  def stBarnabas(), do: stBarnabas(Date.local.year)
  def stBarnabas(year), do: Date.from {year, 6, 11 }
  def nativityOfJohnTheBaptist(), do: nativityOfJohnTheBaptist(Date.local.year)
  def nativityOfJohnTheBaptist(year), do: Date.from {year, 6, 24 }
  def stPeterAndPaul(), do: stPeterAndPaul(Date.local.year)
  def stPeterAndPaul(year), do: Date.from {year, 6, 29 }
  def dominion(), do: dominion(Date.local.year)
  def dominion(year), do: Date.from {year, 7, 1 }
  def independence(), do: independence(Date.local.year)
  def independence(year), do: Date.from {year, 7, 4 }
  def stMaryMagdalene(), do: stMaryMagdalene(Date.local.year)
  def stMaryMagdalene(year), do: Date.from {year, 7, 22 }
  def stJames(), do: stJames(Date.local.year)
  def stJames(year), do: Date.from {year, 7, 25 }
  def transfiguration(), do: transfiguration(Date.local.year)
  def transfiguration(year), do: Date.from {year, 8, 6 }
  def bvm(), do: bvm(Date.local.year)
  def bvm(year), do: Date.from {year, 8, 15 }
  def stBartholomew(), do: stBartholomew(Date.local.year)
  def stBartholomew(year), do: Date.from {year, 8, 24 }
  def holyCross(), do: holyCross(Date.local.year)
  def holyCross(year), do: Date.from {year, 9, 14}
  def stMatthew(), do: stMatthew(Date.local.year)
  def stMatthew(year), do: Date.from {year, 9, 21 }
  def michaelAllAngels(), do: michaelAllAngels(Date.local.year)
  def michaelAllAngels(year), do: Date.from {year, 9, 29 }
  def stLuke(), do: stLuke(Date.local.year)
  def stLuke(year), do: Date.from {year, 10, 18 }
  def stJames(), do: stJames(Date.local.year)
  def stJames(year), do: Date.from {year, 10, 23 }
  def stsSimonAndJude(), do: stsSimonAndJude(Date.local.year)
  def stsSimonAndJude(year), do: Date.from {year, 10, 28 }
  def remembrance(), do: remembrance(Date.local.year)
  def remembrance(year), do: Date.from {year, 11, 11 }

  # thanksgiving = 4th thursday of november
  def thanksgiving(), do: thanksgiving(Date.local.year)
  def thanksgiving(n) do
    tgd = %{1 => 25, 2 => 24, 3 => 23, 4 => 22, 5 => 28, 6 => 27, 7 => 26}
    dow = Date.from( {n, 11, 1}) |> Date.weekday
    Date.from {n, 11, tgd[dow]}
  end

  def memorial(), do: memorial(Date.local.year)
  def memorial(n) do
    md = %{1 => 28, 2 => 27, 3 => 26, 4 => 25, 5 => 31, 6 => 30, 7 => 29}
    dow = Date.from({n, 5, 28}) |> Date.weekday
    Date.from {n, 5, md[dow]}
  end

end