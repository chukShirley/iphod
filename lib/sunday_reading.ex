require IEx
defmodule SundayReading do
  import Lityear
  defstruct date: "",
            season: "",
            week: "",
            title: "",
            ot: [],
            ps: [],
            nt: [],
            gs: []
end

defmodule SundayLectionary do
  use Timex
  def slMap do
    %{  "advent"            => add_services(4),
        "christmasDay"      => add_services(3),
        "christmas"         => add_services(2),
        "holyName"          => add_services(1),
        "epiphany"          => add_services(9),
        "theEpiphany"       => add_services(1),
        "presentation"      => add_services(1),
        "ashWednesday"      => add_services(1),
        "lent"              => add_services(5),
        "palmSunday"        => add_services(1),
        "holyWeek"          => add_services(6),
        "easterDay"         => add_services(3),
        "easter"            => add_services(7),
        "easterWeek"        => add_services(6),
        "ascension"         => add_services(1),
        "pentecostWeekday"  => add_services(2),
        "proper"            => add_services(29),
        "allSaints"         => add_services(1),
        "holyDays"          => add_holyDays
      }
  end

  def start_link do
    Agent.start_link fn -> build end, name: __MODULE__
  end

  def build do
    import String
    File.open!("./data/acna_sunday.csv", [:read, :utf8])
      |> IO.stream(:line)
      |> Enum.reduce(slMap, fn(ln, d) ->
        ln
          |> split("|")
          |> Enum.map(&strip(&1))
          |> _build(d)
        end)
  end

  def _build(["#"|_], struct), do: struct # comment
  def _build([season, wk, title|readings], struct) do
    readingList =
      readings
        |> Enum.map( fn(el)->
          String.split(el, " or ") |> Enum.map(&(String.strip &1))
        end)
    [season, wk, title, aOT, aPS, aNT, aGs, bOT, bPS, bNT, bGs, cOT, cPS, cNT, cGs| leftover] =
      [season, wk, title] ++ readingList
    # if season == "holyDays", do: IEx.pry
    struct
      |> put_in([season, wk, :a], %{ot: aOT, ps: aPS, nt: aNT, gs: aGs, title: title, season: season, week: wk, date: ""})
      |> put_in([season, wk, :b], %{ot: bOT, ps: bPS, nt: bNT, gs: bGs, title: title, season: season, week: wk, date: ""})
      |> put_in([season, wk, :c], %{ot: cOT, ps: cPS, nt: cNT, gs: cGs, title: title, season: season, week: wk, date: ""})
  end    


  def add_holyDays do
    [ "confessionOfStPeter","conversionOfStPaul","stMatthias","stJoseph","annunciation",
      "stMark","stsPhilipAndJames","visitation","stBarnabas","nativityOfJohnTheBaptist",
      "stPeterAndPaul","dominion","independence","stMaryMagdalene","stJames","transfiguration",
      "bvm","stBartholomew","holyCross","stMatthew","michaelAllAngels","stLuke","stJames",
      "stsSimonAndJude","remembrance","stAndrew","stThomas","stStephen","stJohn","holyInnocents",
      "thanksgiving", "memorial"
    ] |> Enum.reduce(Map.new, fn(key, map)->
        map |> Map.put(key, add_lityear)
      end)
  end

  def add_services(n) do
    (1..n)
      |> Enum.reduce(Map.new, fn(i, d)->
        d |> Map.put("#{i}", add_lityear)
      end)
  end

  def add_lityear() do
    %{a: %SundayReading{}, b: %SundayReading{}, c: %SundayReading{}}
  end

  def identity(), do: Agent.get(__MODULE__, &(&1))
  def readings(season, wk, yr), do: identity[season][wk][yr]
  def next_sunday, do: next_sunday Date.local
  def next_sunday(date) do
    {season, wk, yr, sunday} = Lityear.next_sunday(date)
    %{identity[season][wk][yr] | date: formatted_date sunday}
  end

  def next_holy_day(), do: next_holy_day(Date.local)
  def next_holy_day(date) do
    {st_date, festival} = Lityear.next_holy_day(date)
    %{identity["holyDays"][festival][Lityear.abc_atom st_date] | date: formatted_date st_date}
  end

  def last_sunday(), do: last_sunday Date.local
  def last_sunday(date) do
    {season, wk, yr, sunday} = Lityear.last_sunday(date)
    %{identity[season][wk][yr] | date: formatted_date sunday}
  end

  def formatted_date(d), do: d |> DateFormat.format!("{WDfull} {Mfull} {D}, {YYYY}")
end