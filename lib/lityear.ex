require IEx

defmodule Lityear do
  use Timex

  @leap_day 60
  @sunday 7
  @monday 1
  #  @thursday 4
  @tz "America/Los_Angeles"
  @ordinals %{
    "1" => "1st",
    "2" => "2nd",
    "3" => "3rd",
    "4" => "4th",
    "5" => "5th",
    "6" => "6th",
    "7" => "7th",
    "8" => "8th",
    "9" => "9th",
    "10" => "10th",
    "11" => "11th",
    "12" => "12th",
    "13" => "13th",
    "14" => "14th",
    "15" => "15th",
    "16" => "16th",
    "17" => "17th",
    "18" => "18th",
    "19" => "19th",
    "20" => "20th",
    "21" => "21st",
    "22" => "22nd",
    "23" => "23rd",
    "24" => "24th",
    "25" => "25th",
    "26" => "26th",
    "27" => "27th",
    "28" => "28th",
    "29" => "29th"
  }

  def bad_arg(), do: bad_arg('')
  def bad_arg(s), do: "Eh? " <> s
  def is_date(d), do: is_map(d) and d.__struct__ == Timex.DateTime
  def date_shift(d, arg), do: Timex.shift(d, arg)
  def lityear(), do: lityear(Timex.now(@tz))

  def lityear(d) do
    if Timex.day(d) >= Timex.day(advent(1, d.year)) do
      d.year + 1
    else
      d.year
    end
  end

  def abc(d), do: {"c", "a", "b"} |> elem(d |> lityear() |> rem(3))
  def abc_atom(d), do: {:c, :a, :b} |> elem(d |> lityear() |> rem(3))
  def is_sunday?(), do: Timex.now(@tz) |> Timex.weekday() == @sunday
  def is_sunday?(d), do: Timex.weekday(d) == @sunday
  def is_monday?(), do: Timex.now(@tz) |> Timex.weekday() == @monday
  def is_monday?(d), do: Timex.weekday(d) == @monday

  def days_till_sunday(date) do
    days_till_sunday = %{1 => 6, 2 => 5, 3 => 4, 4 => 3, 5 => 2, 6 => 1, 7 => 7}
    days_till_sunday[Timex.weekday(date)]
  end

  def date_next_sunday(), do: Timex.now(@tz) |> date_next_sunday
  def date_next_sunday(d), do: date_shift(d, days: days_till_sunday(d))
  def date_last_sunday(), do: date_last_sunday(Timex.now(@tz))
  def date_last_sunday(d), do: date_shift(d, days: -Timex.weekday(d))
  def last_sunday(), do: date_last_sunday() |> to_season
  def last_sunday(d), do: date_last_sunday(d) |> to_season
  def next_sunday(), do: date_next_sunday(Timex.now(@tz)) |> to_season
  def next_sunday(d), do: date_next_sunday(d) |> to_season
  def from_now(), do: to_season(Timex.now(@tz))

  def to_season(day, mpep \\ false) do
    sunday = if day |> is_sunday?, do: day, else: day |> date_last_sunday()
    {hd, hd_title} = next_holy_day(day)
    y = lityear(sunday)
    yrABC = abc(sunday)
    dOfMon = "#{day.month}/#{day.day}"

    till_advent = Timex.diff(advent(1, sunday.year), sunday, :weeks)

    till_epiphany = Timex.diff(epiphany(y), sunday, :days)
    from_epiphany = Timex.diff(sunday, epiphany(1, y), :weeks)

    from_christmas = Timex.diff(christmas(1, y), sunday, :weeks)
    # is_christmas = (day |> is_sunday?) && (dOfMon == "12/25")
    # is_holy_name = (day |> is_sunday?) && (dOfMon == "1/1")
    is_christmas1 = dOfMon in ~w(12/25 12/26 12/27 12/28 12/29 12/30 12/31)

    is_christmas2 =
      cond do
        dOfMon in ~w(1/2 1/3 1/4 1/5) -> true
        till_epiphany in 1..4 -> true
        true -> false
      end

    from_easter = Timex.diff(sunday, easter_day(y), :weeks)
    days_till_easter = Timex.diff(easter_day(y), day, :days)

    cond do
      # to whom it may concern...
      # changes the order of these conditions at your peril
      hd == day && !mpep ->
        {"redLetter", hd_title, yrABC, day}

      day |> right_after_ash_wednesday?() ->
        {"ashWednesday", "1", yrABC, day}

      day |> right_after_ascension? ->
        {"ascension", "1", yrABC, day}

      dOfMon == "1/6" ->
        {"theEpiphany", "1", yrABC, day}

      day == christmas(y - 1) ->
        {"christmas", "1", yrABC, day}

      is_christmas2 ->
        {"christmas", "2", yrABC, day}

      is_christmas1 ->
        {"christmas", "1", yrABC, day}

      till_epiphany in 6..11 ->
        {"christmas", "1", yrABC, day}

      # days_till_easter == 2    -> {"goodFriday", "1", yrABC, day}
      days_till_easter in 1..6 ->
        {"holyWeek", to_string(7 - days_till_easter), yrABC, day}

      days_till_easter in -1..-6 ->
        {"easterWeek", to_string(0 - days_till_easter), yrABC, day}

      from_easter in -2..-6 ->
        {"lent", to_string(7 + from_easter), yrABC, day}

      from_easter == -1 ->
        {"palmSunday", "1", yrABC, day}

      from_easter == -7 ->
        {"epiphany", "9", yrABC, day}

      from_easter == -8 ->
        {"epiphany", "8", yrABC, day}

      from_easter == 0 ->
        {"easterDay", "1", yrABC, day}

      from_easter in 0..6 ->
        {"easter", to_string(1 + from_easter), yrABC, day}

      from_easter == 7 ->
        {"pentecost", "1", yrABC, day}

      from_easter == 8 ->
        {"trinity", "1", yrABC, day}

      till_advent in 1..27 ->
        {"proper", to_string(30 - till_advent), yrABC, day}

      till_advent in 0..-3 ->
        {"advent", to_string(1 - till_advent), yrABC, day}

      from_christmas in 0..1 ->
        {"christmas", to_string(from_christmas + 1), day}

      epiphany_before_sunday?(day) ->
        {"epiphany", "0", yrABC, day}

      from_epiphany in 0..8 ->
        {"epiphany", to_string(from_epiphany + 1), yrABC, day}

      true ->
        {"unknown", "unknown", :unknown, day}
    end
  end

  def sundayTitle({season, wk, _yr, date}) do
    case season do
      # for RLD's wk is the RLD title
      "redLetter" ->
        wk

      "ashWednesday" ->
        "Ash Wednesday"

      "ascension" ->
        "Sunday after Ascension"

      "theEpiphany" ->
        "The Epiphany"

      "christmas" ->
        case wk do
          "0" -> ""
          _ -> @ordinals[wk] <> " Sunday of Christmas"
        end

      "holyWeek" ->
        case wk do
          "1" -> "Monday in Holy Week"
          "2" -> "Tuesday in Holy Week"
          "3" -> "Wednesday in Holy Week"
          "4" -> "Maunday Thursday"
          "5" -> "Good Friday"
          "6" -> "Holy Saturday"
          _ -> ""
        end

      "easterWeek" ->
        case wk do
          "1" -> "Monday of Easter Week"
          "2" -> "Tuesday of Easter Week"
          "3" -> "Wednesday of Easter Week"
          "4" -> "Thursday of Easter Week"
          "5" -> "Friday of Easter Week"
          "6" -> "Saturday of Easter Week"
          _ -> ""
        end

      "lent" ->
        @ordinals[wk] <> " Sunday in Lent"

      "palmSunday" ->
        "Palm Sunday"

      "epiphany" ->
        case wk do
          "8" ->
            "Mission Sunday"

          "9" ->
            "Last Sunday of Epiphany"

          # days following epiphany and before sunday
          "0" ->
            ""

          _ ->
            @ordinals[wk] <> " Sunday of Epiphany"
        end

      "easterDay" ->
        "Easter Day"

      "easter" ->
        @ordinals[wk] <> " Sunday of Easter"

      "pentecost" ->
        "Pentecost"

      "trinity" ->
        "Trinity Sunday"

      "proper" ->
        sundayBetween(date)

      "advent" ->
        @ordinals[wk] <> " Sunday in Advent"

      _ ->
        ""
    end
  end

  def sundayBetween(date) do
    sb = "Sunday between "

    cond do
      date
      |> date_in_range(Date.from_erl!({date.year, 5, 8}), Date.from_erl!({date.year, 5, 14})) ->
        sb <> "May 8 and May 14"

      date
      |> date_in_range(Date.from_erl!({date.year, 5, 15}), Date.from_erl!({date.year, 5, 21})) ->
        sb <> "May 15 and May 21 "

      date
      |> date_in_range(Date.from_erl!({date.year, 5, 22}), Date.from_erl!({date.year, 5, 28})) ->
        sb <> "May 22 and May 28 "

      date
      |> date_in_range(Date.from_erl!({date.year, 5, 29}), Date.from_erl!({date.year, 6, 4})) ->
        sb <> "May 29 and June 4"

      date
      |> date_in_range(Date.from_erl!({date.year, 6, 5}), Date.from_erl!({date.year, 6, 11})) ->
        sb <> "June 5 and June 11"

      date
      |> date_in_range(Date.from_erl!({date.year, 6, 12}), Date.from_erl!({date.year, 6, 18})) ->
        sb <> "June 12 and June 18"

      date
      |> date_in_range(Date.from_erl!({date.year, 6, 19}), Date.from_erl!({date.year, 6, 25})) ->
        sb <> "June 19 and June 25"

      date
      |> date_in_range(Date.from_erl!({date.year, 6, 26}), Date.from_erl!({date.year, 7, 2})) ->
        sb <> "June 26 and July 2"

      date
      |> date_in_range(Date.from_erl!({date.year, 7, 3}), Date.from_erl!({date.year, 7, 9})) ->
        sb <> "July 3 and July 9"

      date
      |> date_in_range(Date.from_erl!({date.year, 7, 10}), Date.from_erl!({date.year, 7, 16})) ->
        sb <> "July 10 and July 16"

      date
      |> date_in_range(Date.from_erl!({date.year, 7, 17}), Date.from_erl!({date.year, 7, 23})) ->
        sb <> "July 17 and July 23"

      date
      |> date_in_range(Date.from_erl!({date.year, 7, 24}), Date.from_erl!({date.year, 7, 30})) ->
        sb <> "July 24 and July 30"

      date
      |> date_in_range(Date.from_erl!({date.year, 7, 31}), Date.from_erl!({date.year, 8, 6})) ->
        sb <> "July 31 and August 6"

      date
      |> date_in_range(Date.from_erl!({date.year, 8, 7}), Date.from_erl!({date.year, 8, 13})) ->
        sb <> "August 7 and August 13"

      date
      |> date_in_range(Date.from_erl!({date.year, 8, 14}), Date.from_erl!({date.year, 8, 20})) ->
        sb <> "August 14 and August 20"

      date
      |> date_in_range(Date.from_erl!({date.year, 8, 21}), Date.from_erl!({date.year, 8, 27})) ->
        sb <> "August 21 and August 27"

      date
      |> date_in_range(Date.from_erl!({date.year, 8, 28}), Date.from_erl!({date.year, 9, 3})) ->
        sb <> "August 28 and September 3"

      date
      |> date_in_range(Date.from_erl!({date.year, 9, 4}), Date.from_erl!({date.year, 9, 10})) ->
        sb <> "September 4 and September 10"

      date
      |> date_in_range(Date.from_erl!({date.year, 9, 11}), Date.from_erl!({date.year, 9, 17})) ->
        sb <> "September 11 and September 17"

      date
      |> date_in_range(Date.from_erl!({date.year, 9, 18}), Date.from_erl!({date.year, 9, 24})) ->
        sb <> "September 18 and September 24"

      date
      |> date_in_range(Date.from_erl!({date.year, 9, 25}), Date.from_erl!({date.year, 10, 1})) ->
        sb <> "September 25 and October 1"

      date
      |> date_in_range(Date.from_erl!({date.year, 10, 2}), Date.from_erl!({date.year, 10, 8})) ->
        sb <> "October 2 and October 8"

      date
      |> date_in_range(Date.from_erl!({date.year, 10, 9}), Date.from_erl!({date.year, 10, 15})) ->
        sb <> "October 9 and October 15"

      date
      |> date_in_range(Date.from_erl!({date.year, 10, 16}), Date.from_erl!({date.year, 10, 22})) ->
        sb <> "October 16 and October 22"

      date
      |> date_in_range(Date.from_erl!({date.year, 10, 23}), Date.from_erl!({date.year, 10, 29})) ->
        sb <> "October 23 and October 29"

      date
      |> date_in_range(Date.from_erl!({date.year, 10, 30}), Date.from_erl!({date.year, 11, 5})) ->
        sb <> "October 30 and November 5"

      date
      |> date_in_range(Date.from_erl!({date.year, 11, 6}), Date.from_erl!({date.year, 11, 12})) ->
        sb <> "November 6 and November 12"

      date
      |> date_in_range(Date.from_erl!({date.year, 11, 13}), Date.from_erl!({date.year, 11, 19})) ->
        sb <> "November 13 and November 19"

      date
      |> date_in_range(Date.from_erl!({date.year, 11, 20}), Date.from_erl!({date.year, 11, 26})) ->
        sb <> "November 20 and November 26"

      true ->
        ""
    end
  end

  def date_in_range(date, first, last) do
    Date.range(first, last) |> Enum.member?(date)
  end

  def epiphany_before_sunday?(date) do
    before_epiphany = Date.compare(date, epiphany(date.year)) == :lt
    after_epiphany1 = Date.compare(epiphany(1, date.year), date) == :gt

    cond do
      before_epiphany ->
        false

      after_epiphany1 ->
        true

      # between epiphany & 1st Sunday Epiphany
      true ->
        false
    end
  end

  def next_season("advent", date) do
    if Timex.before?(advent(), date), do: advent(1, date.year + 1), else: advent()
  end

  def next_season("epiphany", date) do
    if Timex.before?(epiphany(), date), do: epiphany(1, date.year + 1), else: epiphany()
  end

  def next_season("lent", date) do
    if Timex.before?(lent(), date), do: lent(1, date.year + 1), else: lent()
  end

  def next_season("easter", date) do
    if Timex.before?(easter(), date), do: easter(1, date.year + 1), else: easter()
  end

  def next_season("pentecost", date) do
    if Timex.before?(pentecost(), date), do: pentecost(1, date.year + 1), else: pentecost()
  end

  def advent(), do: advent(1)
  def advent(n), do: christmas() |> date_last_sunday() |> date_shift(weeks: n - 4)
  def advent(n, y), do: christmas(y) |> date_last_sunday() |> date_shift(weeks: n - 4)

  def christmas(), do: Timex.to_date({Timex.now(@tz).year, 12, 25})
  def christmas(n) when n < 1, do: {:error, "There is no Christmas before year 0"}
  # presume n is a year
  def christmas(n) when n > 2, do: Timex.to_date({n, 12, 25})
  # n is 1 or 2, presume sunday after christmas
  def christmas(n) do
    christmas() |> date_next_sunday |> date_shift(weeks: n - 1)
  end

  def christmas(n, y), do: christmas(y) |> date_shift(weeks: n)

  def christmasDay?(d), do: d.year |> christmas == d

  def inChristmas?(date) do
    "#{date.month}/#{date.day}" in ~w(12/25 12/26 12/27 12/28 12/29 12/30 12/31 1/1 1/2 1/3 1/4 1/5)
  end

  def epiphany(), do: Timex.to_date({lityear(), 1, 6})
  def epiphany(n) when n < 1, do: {:error, "There is no Epiphany before year 0."}
  def epiphany(n) when n in 1..9, do: epiphany(n, Timex.now(@tz).year)
  def epiphany(n) when is_integer(n), do: Timex.to_date({{n, 1, 6}, {0, 0, 0}})
  def epiphany(d), do: Timex.to_date({{d.year, 1, 6}, {0, 0, 0}})

  def epiphany(n, yr) do
    Timex.to_date({{yr, 1, 6}, {0, 0, 0}}) |> date_next_sunday |> date_shift(weeks: n - 1)
  end

  def epiphany_last(), do: date_last_sunday(ash_wednesday())
  def epiphany_last(yr), do: date_last_sunday(ash_wednesday(yr))

  def ash_wednesday(), do: date_shift(easter(), days: -46)
  def ash_wednesday(y) when is_integer(y), do: date_shift(_easter(y), days: -46)
  def ash_wednesday(d), do: date_shift(_easter(d.year), days: -46)

  def right_after_ash_wednesday?(d) do
    aw = ash_wednesday(d)
    lent? = Date.compare(d, aw) != :lt
    before_lent1? = Date.compare(d, lent(1, d)) == :lt
    lent? && before_lent1?
  end

  def lent(), do: ash_wednesday() |> date_next_sunday
  def lent(n) when n < 6, do: lent(n, Timex.now(@tz).year)
  def lent(y), do: ash_wednesday(y) |> date_next_sunday
  def lent(n, yr), do: lent(yr) |> date_shift(weeks: n - 1)

  def palm_sunday(), do: easter() |> date_shift(weeks: -1)
  def palm_sunday(year), do: easter(year) |> date_shift(weeks: -1)

  def good_friday(), do: easter() |> date_shift(days: -2)
  def good_friday(year), do: easter(year) |> date_shift(days: -2)
  def good_friday?(d), do: d.year |> good_friday == d

  def easter(), do: lityear(Timex.now(@tz)) |> _easter()
  def easter(n) when n >= 30, do: _easter(n)
  def easter(n) when n in 1..7, do: easter() |> date_shift(weeks: n - 1)
  def easter(_n), do: {:error, "Eh? There is no Easter before the Resurrection!"}
  def easter_day(year), do: _easter(year)
  def easter(week, year), do: date_shift(_easter(year), weeks: week - 1)

  @doc """
  algorithm from `http://en.wikipedia.org/wiki/Computus#cite_note-otheralgs-47
  """
  def _easter(year) do
    a = rem(year, 19)
    b = div(year, 100)
    c = rem(year, 100)
    d = div(b, 4)
    e = rem(b, 4)
    f = div(b + 8, 25)
    g = div(b - f + 1, 3)
    h = rem(19 * a + b - d - g + 15, 30)
    i = div(c, 4)
    k = rem(c, 4)
    l = rem(32 + 2 * e + 2 * i - h - k, 7)
    m = div(a + 11 * h + 22 * l, 451)
    month = div(h + l - 7 * m + 114, 31)
    day = rem(h + l - 7 * m + 114, 31) + 1
    Timex.to_date({year, month, day})
  end

  def second_monday_after_easter(), do: second_monday_after_easter(lityear())
  def second_monday_after_easter(n), do: _easter(n) |> Timex.shift(days: 8)
  # 39 days from east to ascension
  def ascension(), do: lityear(Timex.now(@tz)) |> _easter() |> date_shift(days: 39)
  # 39 days from east to ascension
  def ascension(n), do: n |> _easter() |> date_shift(days: 39)
  def sunday_after_ascension(), do: easter(7)
  # no easters before 30AD
  def sunday_after_ascension(year) when year >= 30, do: easter(7, year)
  def pentecost(), do: pentecost(1, lityear())
  def pentecost(n), do: pentecost(n, lityear())
  def pentecost(n, y), do: easter(n + 7, y)

  def right_after_ascension?(d) do
    a = ascension(d.year)
    ascension? = Date.compare(d, a) != :lt
    # saad - sunday after ascension day
    before_saad? = Date.compare(d, sunday_after_ascension(d.year)) == :lt
    ascension? && before_saad?
  end

  def trinity(), do: pentecost(2, lityear())
  def trinity(y), do: pentecost(2, y)
  def proper(n) when n < 30, do: proper(n, lityear())

  def proper(d) do
    29 - Timex.diff(d, Lityear.advent(0, d.year), :weeks)
  end

  def proper(n, yr) when is_integer(n), do: advent(n - 29, yr)

  def sunday_to_date('easter', week, year), do: easter(week, year)
  def sunday_to_date('pentecost', week, year), do: pentecost(week, year)
  def sunday_to_date('trinity', _week, year), do: pentecost(2, year)
  def sunday_to_date('proper', week, year), do: proper(week, year)
  def sunday_to_date('advent', week, year), do: advent(week, year)
  def sunday_to_date('christmas', week, year), do: christmas(week, year)
  def sunday_to_date('epiphany', week, year), do: epiphany(week, year)
  def sunday_to_date('lent', week, year), do: epiphany(week, year)

  def hd_title(key) do
    %{
      "epiphany" => "The Epiphany",
      "confessionOfStPeter" => "Confession Of St. Peter",
      # "confessionOfStPeter" => "confessionOfStPeter", # for dates at end of dec
      "conversionOfStPaul" => "Conversion Of St. Paul",
      "presentation" => "Presentation",
      "stMatthias" => "St. Matthias",
      "stJoseph" => "St. Joseph",
      "annunciation" => "Annunciation",
      "stMark" => "St. Mark",
      "stsPhilipAndJames" => "Sts. Philip And James",
      "visitation" => "Visitation",
      "stBarnabas" => "St. Barnabas",
      "nativityOfJohnTheBaptist" => "Nativity Of John The Baptist",
      "stPeterAndPaul" => "Sts. Peter And Paul",
      "dominion" => "Dominion Day",
      "independence" => "Independence Day",
      "stMaryMagdalene" => "St. Mary Magdalene",
      "stJames" => "St. James",
      "transfiguration" => "Transfiguration",
      "bvm" => "Blessed Virgin Mary",
      "stBartholomew" => "St. Bartholomew",
      "holyCross" => "Holy Cross",
      "stMatthew" => "St. Matthew",
      "michaelAllAngels" => "Michael and All Angels",
      "stLuke" => "St. Luke",
      "stsSimonAndJude" => "Sts. Simon And Jude",
      "allSaints" => "All Saints",
      "remembrance" => "Remembrance Day",
      "stAndrew" => "St. Andrew",
      "stThomas" => "St. Thomas",
      "christmasEve" => "Christmas Eve",
      "christmasDay" => "Christmas Day",
      "stStephen" => "St. Stephen",
      "stJohn" => "St. John",
      "holyInnocents" => "Holy Innocents"
    }[key]
  end

  def hd_index() do
    %{
      6 => "epiphany",
      18 => "confessionOfStPeter",
      # for dates at end of dec
      382 => "confessionOfStPeter",
      25 => "conversionOfStPaul",
      33 => "presentation",
      55 => "stMatthias",
      78 => "stJoseph",
      84 => "annunciation",
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
      305 => "allSaints",
      315 => "remembrance",
      333 => "stAndrew",
      355 => "stThomas",
      358 => "christmasEve",
      359 => "christmasDay",
      360 => "stStephen",
      361 => "stJohn",
      362 => "holyInnocents"
    }
  end

  # Holy Day, Day of Year
  def hd_doy() do
    # zero indexed
    [
      0,
      # jan
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      18,
      25,
      25,
      25,
      25,
      25,
      25,
      25,
      33,
      33,
      33,
      33,
      33,
      33,
      # feb
      33,
      33,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      55,
      78,
      78,
      78,
      78,
      # mar
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      78,
      84,
      84,
      84,
      84,
      84,
      84,
      115,
      115,
      115,
      115,
      115,
      115,
      # apr
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      115,
      121,
      121,
      121,
      121,
      121,
      # may
      121,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      151,
      # jun
      162,
      162,
      162,
      162,
      162,
      162,
      162,
      162,
      162,
      162,
      162,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      175,
      180,
      180,
      180,
      180,
      180,
      182,
      # jul
      182,
      185,
      185,
      185,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      203,
      206,
      206,
      206,
      218,
      218,
      218,
      218,
      218,
      218,
      # aug
      218,
      218,
      218,
      218,
      218,
      218,
      227,
      227,
      227,
      227,
      227,
      227,
      227,
      227,
      227,
      236,
      236,
      236,
      236,
      236,
      236,
      236,
      236,
      236,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      # sep
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      257,
      264,
      264,
      264,
      264,
      264,
      264,
      264,
      272,
      272,
      272,
      272,
      272,
      272,
      272,
      272,
      291,
      # oct
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      291,
      296,
      296,
      296,
      296,
      296,
      301,
      301,
      301,
      301,
      301,
      305,
      305,
      305,
      # nov
      305,
      315,
      315,
      315,
      315,
      315,
      315,
      315,
      315,
      315,
      315,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      333,
      # dec
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      355,
      361,
      361,
      361,
      361,
      361,
      362,
      382,
      382,
      382,
      382
    ]
  end

  def holy_day?(date) do
    # need to check if date is a sunday and 
    # if yesterday was sunday and and holy day
    # this should probably handle christmas & epiphany
    # since they float around like a holy day
    # d is numerical day of year; 1-365 or 1-366
    d = leap_year_correction(date)

    cond do
      # don't translate Christmas Eve
      hd_index()[d] == "christmasEve" && date |> is_sunday? ->
        {true, "advent4ChristmasEve"}

      # don't translate Christmas
      hd_index()[d] == "christmasDay" ->
        {true, "christmasDay"}

      # don't translate The Presentation
      hd_index()[d] == "presentation" ->
        {true, "presentation"}

      # potential problem for feast of Our Lord
      date |> is_sunday? ->
        {false, ""}

      date |> is_monday? ->
        # go back a day and check
        holy_day = hd_index()[d - 1]
        if holy_day |> is_nil, do: {false, ""}, else: {true, holy_day}

      hd_index()[d] |> is_nil ->
        {false, ""}

      true ->
        {true, hd_index()[d]}
    end
  end

  # next holy day is confusing because if today is sunday
  # you have to move the holy day to monday, which means
  # if the doy of week is a monday you have to see if yesterday (a sunday)
  # was a holy day. There is also the unusual case where both sunday and monday
  # are holy days necessitating a double translation
  # at which point, for the time being, I give up
  def next_holy_day(date) do
    case weekday = Timex.weekday(date) do
      @monday -> date |> date_shift(days: -1) |> next_holy_day
      _ -> _next_holy_day(date, weekday, leap_year_correction?(date))
    end
  end

  # correct for leap year
  def _next_holy_day(date, _weekday, true) do
    this_doy = (date |> Timex.day()) - 1
    holy_doy = hd_doy() |> Enum.at(this_doy)
    new_date = Timex.from_iso_day(1, date) |> Timex.shift(days: holy_doy)
    new_date = if holy_doy > 365, do: new_date |> Timex.shift(days: 1), else: new_date
    {new_date, hd_index()[holy_doy]}
  end

  # no leap year correction required
  def _next_holy_day(date, _weekday, false) do
    this_doy = date |> Timex.day()
    holy_doy = hd_doy() |> Enum.at(this_doy)
    new_date = Timex.from_iso_day(1, date) |> Timex.shift(days: holy_doy - 1)
    new_date = if holy_doy > 365, do: new_date |> Timex.shift(days: 1), else: new_date
    # if it's a sunday, shift to monday
    new_date = new_date |> translate_from_sunday()
    {new_date, hd_index()[holy_doy]}
  end

  def leap_year_correction(date) do
    _leap_year_correction(date, Timex.is_leap?(date))
  end

  def _leap_year_correction(date, false), do: date |> Timex.day()

  def _leap_year_correction(date, true) do
    n = date |> Timex.day()
    if n > @leap_day, do: n - 1, else: n
  end

  def leap_year_correction?(date), do: Timex.is_leap?(date) && date |> Timex.day() > @leap_day

  def namedDayDate("christmasEve", _wk), do: Timex.to_date({Timex.now(@tz).year, 12, 24})
  def namedDayDate("christmasDay", _wk), do: Timex.to_date({Timex.now(@tz).year, 12, 25})
  def namedDayDate("holyName", _wk), do: Timex.to_date({Timex.now(@tz).year, 1, 1})
  def namedDayDate("palmSundayPalms", _wk), do: palm_sunday()
  def namedDayDate("palmSunday", _wk), do: palm_sunday()

  def namedDayDate("holyWeek", wk) when wk |> is_bitstring,
    do: namedDayDate("holyWeek", wk |> String.to_integer())

  def namedDayDate("holyWeek", wk), do: palm_sunday() |> date_shift(days: wk)
  def namedDayDate("easterDayVigil", _wk), do: easter() |> date_shift(days: -1)

  #  def namedDayDate("easterDay", wk) when wk |> is_bitstring, do: namedDayDate("easterDay", wk |> String.to_integer) 
  def namedDayDate("easterDay", _wk), do: easter()

  def namedDayDate("easterWeek", wk) when wk |> is_bitstring,
    do: namedDayDate("easterWeek", wk |> String.to_integer())

  def namedDayDate("easterWeek", wk), do: easter() |> date_shift(days: wk)

  def christmasEve(), do: christmasEve(Timex.now(@tz).year)
  def christmasEve(year), do: Timex.to_date({year, 12, 24})

  def stAndrew(), do: stAndrew(Timex.now(@tz).year)
  def stAndrew(year), do: Timex.to_date({year, 11, 30}) |> translate_from_sunday
  def stThomas(), do: stThomas(Timex.now(@tz).year)
  def stThomas(year), do: Timex.to_date({year, 12, 21}) |> translate_from_sunday
  def stStephen(), do: stStephen(Timex.now(@tz).year)
  def stStephen(year), do: Timex.to_date({year, 12, 26}) |> translate_from_sunday
  def stJohn(), do: stJohn(Timex.now(@tz).year)
  def stJohn(year), do: Timex.to_date({year, 12, 27}) |> translate_from_sunday
  def holyInnocents(), do: holyInnocents(Timex.now(@tz).year)
  def holyInnocents(year), do: Timex.to_date({year, 12, 28}) |> translate_from_sunday
  def confessionOfStPeter(), do: confessionOfStPeter(Timex.now(@tz).year)
  def confessionOfStPeter(year), do: Timex.to_date({year, 1, 18}) |> translate_from_sunday
  def conversionOfStPaul(), do: conversionOfStPaul(Timex.now(@tz).year)
  def conversionOfStPaul(year), do: Timex.to_date({year, 1, 25}) |> translate_from_sunday
  def presentation(), do: presentation(Timex.now(@tz).year)
  def presentation(year), do: Timex.to_date({year, 2, 2}) |> translate_from_sunday
  def stMatthias(), do: stMatthias(Timex.now(@tz).year)
  def stMatthias(year), do: Timex.to_date({year, 2, 24}) |> translate_from_sunday
  def stJoseph(), do: stJoseph(Timex.now(@tz).year)
  def stJoseph(year), do: Timex.to_date({year, 3, 19}) |> translate_from_sunday
  def annunciation(), do: annunciation(Timex.now(@tz).year)
  def annunciation(year), do: Timex.to_date({year, 3, 25}) |> translate_from_sunday
  def stMark(), do: stMark(Timex.now(@tz).year)
  def stMark(year), do: Timex.to_date({year, 4, 25}) |> translate_from_sunday
  def stsPhilipAndJames(), do: stsPhilipAndJames(Timex.now(@tz).year)
  def stsPhilipAndJames(year), do: Timex.to_date({year, 5, 1}) |> translate_from_sunday
  def visitation(), do: visitation(Timex.now(@tz).year)
  def visitation(year), do: Timex.to_date({year, 5, 31}) |> translate_from_sunday
  def stBarnabas(), do: stBarnabas(Timex.now(@tz).year)
  def stBarnabas(year), do: Timex.to_date({year, 6, 11}) |> translate_from_sunday
  def nativityOfJohnTheBaptist(), do: nativityOfJohnTheBaptist(Timex.now(@tz).year)
  def nativityOfJohnTheBaptist(year), do: Timex.to_date({year, 6, 24}) |> translate_from_sunday
  def stPeterAndPaul(), do: stPeterAndPaul(Timex.now(@tz).year)
  def stPeterAndPaul(year), do: Timex.to_date({year, 6, 29}) |> translate_from_sunday
  def dominion(), do: dominion(Timex.now(@tz).year)
  def dominion(year), do: Timex.to_date({year, 7, 1}) |> translate_from_sunday
  def independence(), do: independence(Timex.now(@tz).year)
  def independence(year), do: Timex.to_date({year, 7, 4}) |> translate_from_sunday
  def stMaryMagdalene(), do: stMaryMagdalene(Timex.now(@tz).year)
  def stMaryMagdalene(year), do: Timex.to_date({year, 7, 22}) |> translate_from_sunday
  def stJames(), do: stJames(Timex.now(@tz).year)
  def stJames(year), do: Timex.to_date({year, 7, 25}) |> translate_from_sunday
  def transfiguration(), do: transfiguration(Timex.now(@tz).year)
  def transfiguration(year), do: Timex.to_date({year, 8, 6}) |> translate_from_sunday
  def bvm(), do: bvm(Timex.now(@tz).year)
  def bvm(year), do: Timex.to_date({year, 8, 15}) |> translate_from_sunday
  def stBartholomew(), do: stBartholomew(Timex.now(@tz).year)
  def stBartholomew(year), do: Timex.to_date({year, 8, 24}) |> translate_from_sunday
  def holyCross(), do: holyCross(Timex.now(@tz).year)
  def holyCross(year), do: Timex.to_date({year, 9, 14}) |> translate_from_sunday
  def stMatthew(), do: stMatthew(Timex.now(@tz).year)
  def stMatthew(year), do: Timex.to_date({year, 9, 21}) |> translate_from_sunday
  def michaelAllAngels(), do: michaelAllAngels(Timex.now(@tz).year)
  def michaelAllAngels(year), do: Timex.to_date({year, 9, 29}) |> translate_from_sunday
  def stLuke(year), do: Timex.to_date({year, 10, 18}) |> translate_from_sunday
  def stLuke(), do: stLuke(Timex.now(@tz).year)
  def stJamesOfJerusalem(year), do: Timex.to_date({year, 10, 23}) |> translate_from_sunday
  def stJamesOfJerusalem(), do: stJames(Timex.now(@tz).year)
  def stsSimonAndJude(), do: stsSimonAndJude(Timex.now(@tz).year)
  def stsSimonAndJude(year), do: Timex.to_date({year, 10, 28}) |> translate_from_sunday
  def remembrance(), do: remembrance(Timex.now(@tz).year)
  def remembrance(year), do: Timex.to_date({year, 11, 11}) |> translate_from_sunday

  def translate_from_sunday(date) do
    if date |> is_sunday?, do: date |> Timex.shift(days: 1), else: date
  end

  # thanksgiving = 4th thursday of november
  def thanksgiving(), do: thanksgiving(Timex.now(@tz).year)

  def thanksgiving(n) do
    tgd = %{1 => 25, 2 => 24, 3 => 23, 4 => 22, 5 => 28, 6 => 27, 7 => 26}
    dow = Timex.to_date({n, 11, 1}) |> Timex.weekday()
    Timex.to_date({n, 11, tgd[dow]})
  end

  def memorial(), do: memorial(Timex.now(@tz).year)

  def memorial(n) do
    md = %{1 => 28, 2 => 27, 3 => 26, 4 => 25, 5 => 31, 6 => 30, 7 => 29}
    dow = Timex.to_date({n, 5, 28}) |> Timex.weekday()
    Timex.to_date({n, 5, md[dow]})
  end
end
