require IEx
defmodule  Lityear do
  use Timex

  @leap_day 60
  @sunday 7
  @monday 1
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
  def is_monday?(), do: Date.now(@tz) |> Timex.weekday == @monday
  def is_monday?(d), do: Timex.weekday(d) == @monday
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

    # Timex.diff is a scaler not a vector
    # that's why the second step
    # see also from_easter
    till_advent = Timex.diff(sunday, advent(1, sunday.year), :weeks)
    till_advent = if sunday |> Timex.before?( advent(1, sunday.year)), do: till_advent, else: -till_advent

    from_christmas = Timex.diff(sunday, christmas(1, y), :weeks)

    from_easter = Timex.diff(easter_day(y), sunday, :weeks) |> abs
    from_easter = if easter_day(y) |> Timex.before?(sunday), do: from_easter, else: -from_easter

    till_epiphany = Timex.diff(sunday, epiphany(y), :days)
    till_epiphany = if sunday |> Timex.before?(epiphany(y)), do: till_epiphany, else: -till_epiphany
    
    from_epiphany = Timex.diff(epiphany(1, y), sunday, :weeks)

    # IO.puts "TILL EPIPHANY: #{till_epiphany}"
    # IO.puts "FROM EPIPHANY: #{from_epiphany}"
    # IO.puts "FROM EASTER: #{from_easter}"

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
  def second_monday_after_easter(), do: second_monday_after_easter(lityear)
  def second_monday_after_easter(n), do: _easter(n) |> Timex.shift(days: 8)
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

  defp hd_index() do
    %{  18  => "confessionOfStPeter",
        382 => "confessionOfStPeter", # for dates at end of dec
        25  => "conversionOfStPaul",
        55  => "stMatthias",
        78  => "stJoseph",
        84  => "annunciation",
        115 => "stMark",
        121 => "stsPhilipAndJames",
        151 => "visitation",
        162 => "stBarnabas",
        175 => "nativityOfJohnTheBaptist",
        180 => "stPeterAndPaul",
        182 => "dominion",
        185 => "independence",
        203 => "stMaryMagdalene",
        206 => "stJames",
        218 => "transfiguration",
        227 => "bvm",
        236 => "stBartholomew",
        257 => "holyCross",
        264 => "stMatthew",
        272 => "michaelAllAngels",
        291 => "stLuke",
        296 => "stJames",
        301 => "stsSimonAndJude",
        315 => "remembrance",
        333 => "stAndrew",
        355 => "stThomas",
        361 => "stStephen",
        361 => "stJohn",
        362 => "holyInnocents"
    }
  end
  defp hd_doy() do
    [ 0, # zero indexed
      18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,18,25,25,25,25,25,25,25,55,55,55,55,55,55,  # jan
      55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,55,78,78,78,78,           # feb
      78,78,78,78,78,78,78,78,78,78,78,78,78,78,78,78,78,78,78,84,84,84,84,84,84,115,115,115,115,115,115,  # mar
      115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,115,121,121,121,121,121,     # apr
      121,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151,151, # may
      162,162,162,162,162,162,162,162,162,162,162,175,175,175,175,175,175,175,175,175,175,175,175,175,180,180,180,180,180,182,     # jun
      182,185,185,185,203,203,203,203,203,203,203,203,203,203,203,203,203,203,203,203,203,203,206,206,206,218,218,218,218,218,218, # jul
      218,218,218,218,218,218,227,227,227,227,227,227,227,227,227,236,236,236,236,236,236,236,236,236,257,257,257,257,257,257,257, # aug
      257,257,257,257,257,257,257,257,257,257,257,257,257,257,264,264,264,264,264,264,264,272,272,272,272,272,272,272,272,291,     # sep
      291,291,291,291,291,291,291,291,291,291,291,291,291,291,291,291,291,291,296,296,296,296,296,301,301,301,301,301,315,315,315, # oct
      315,315,315,315,315,315,315,315,315,315,315,333,333,333,333,333,333,333,333,333,333,333,333,333,333,333,333,333,333,333,     # nov
      355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,355,361,361,361,361,361,362,382,382,382,382  # dec
    ]
  end

  def next_holy_day(date) do # {date_of_holy_day, name_of_holy_day}
    _next_holy_day(date, Timex.weekday(date))
  end

  def _next_holy_day(date, @sunday) do
    _next_holy_day(date, @sunday, 1)
  end

  def _next_holy_day(date, @monday) do
    date |> date_shift(days: -1) |> next_holy_day
  end

  def _next_holy_day(date, weekday) do
    _next_holy_day(date, weekday, 0)
  end

  def _next_holy_day(date, _, n) do
    this_day = leap_year_correction(date)
    day = hd_doy |> Enum.at(this_day)
    hd_date = Timex.date({date.year, 1, 1}) |> date_shift(days: day + n)
    {hd_date, hd_index[day]}
  end

  def leap_year_correction(date) do
    _leap_year_correction(date, Timex.is_leap?(date))
  end
  def _leap_year_correction(date, false), do: date |> Timex.day
  def _leap_year_correction(date, true) do
    n = date |> Timex.day
    if n > @leap_day, do: n - 1, else: n
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