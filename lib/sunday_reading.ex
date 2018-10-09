require IEx

defmodule SundayReading do
  import Lityear, only: [namedDayDate: 2]
  use Timex
  @tz "America/Los_Angeles"

  def start_link do
    Agent.start_link(fn -> build() end, name: __MODULE__)
  end

  def identity(), do: Agent.get(__MODULE__, & &1)
  def seasons(), do: identity() |> Map.keys()
  def weeks_for(season), do: identity()[season] |> Map.keys()

  # special to send all gospel lessons to file
  def all_lessons() do
    {:ok, file} = File.open("sr.text", [:write, :utf8])

    readingList()
    |> Enum.each(fn {season, week, year} ->
      titlesAndColors = identity()[season][week]

      IO.puts(
        file,
        "#{season}, #{week} #{year} - #{titlesAndColors["title"]}; #{
          titlesAndColors["colors"] |> Enum.join(", ")
        }"
      )

      this_week = identity()[season][week][year]
      # putText(file, :ot, this_week.ot)
      # putText(file, :ps, this_week.ps)
      # putText(file, :nt, this_week.nt)
      putText(file, :gs, this_week.gs)
      IO.puts(file, "-----")
      # IO.puts file, "OT: #{inspect this_week.ot}"
      # IO.puts file, "PS: #{inspect this_week.ps}"
      # IO.puts file, "NT: #{inspect this_week.nt}"
      # IO.puts file, "GS: #{inspect this_week.gs}"
      :timer.sleep(200)
    end)

    file |> File.close()
  end

  def putText(file, lessonType, list) do
    lesson = [ot: "First Lesson", ps: "Psalm", nt: "Second Lesson", gs: "The Gospel"]
    trans = [ot: "ESV", ps: "BCP", nt: "ESV", gs: "ESV"]
    IO.puts(file, "\t" <> lesson[lessonType])
    _putText(file, lessonType |> Atom.to_string(), trans[lessonType], list)
  end

  def _putText(file, "ps", _trans, []), do: IO.puts(file, "\n")
  def _putText(file, _lessonType, _trans, []), do: IO.puts(file, "\t\t\tThe Word of the Lord\n")

  def _putText(file, "ps", trans, [h | t]) do
    lesson = BCPPsalms.get(h.read) |> Enum.join("\n")

    case h.style do
      "opt" ->
        IO.puts(file, "\t\t[ " <> lesson <> " ]")

      "alt" ->
        IO.puts(file, "\t\t~~~ OR ~~~\n\t\t" <> lesson)

      "alt-opt" ->
        "\t\t~~~ OR ~~~\n\t\t[ " <> lesson <> " ]"

      "alt-req" ->
        "\t\t~~~ OR ~~~\n\t\t[ " <> lesson <> " ]"

      "req" ->
        IO.puts(file, "\t\t" <> lesson)

      # shouldn't happen
      _ ->
        IO.puts(file, "\t\t??? " <> h.style <> "\n\t\t" <> lesson)
    end

    _putText(file, "ps", trans, t)
  end

  def _putText(file, lessonType, trans, [h | t]) do
    passage = h.read |> String.replace(":", ".")

    keywords = [
      include_footnotes: "false",
      output_format: "plain-text",
      passage: passage,
      include_headings: "false",
      include_subheadings: "false",
      include_audio_link: "false",
      include_heading_horizontal_lines: false
    ]

    lesson = EsvText.request_raw(keywords)
    # lesson = h.read
    case h.style do
      "opt" ->
        IO.puts(file, "\t\t[ " <> lesson <> " ]")

      "alt" ->
        IO.puts(file, "\t\t~~~ OR ~~~\n\t\t" <> lesson)

      "alt-opt" ->
        "\t\t~~~ OR ~~~\n\t\t[ " <> lesson <> " ]"

      "alt-req" ->
        "\t\t~~~ OR ~~~\n\t\t[ " <> lesson <> " ]"

      "req" ->
        IO.puts(file, "\t\t" <> lesson)

      # shouldn't happen
      _ ->
        IO.puts(file, "\t\t??? " <> h.style <> "\n\t\t" <> lesson)
    end

    _putText(file, lessonType, trans, t)
  end

  # EsvText.request_raw [include_footnotes: "false", output_format: "plain-text", passage: "john 3:1-16"]
  def list_seasons() do
    {:ok, file} = File.open("sr.text", [:write, :utf8])

    identity()
    |> Map.to_list()
    |> Enum.each(fn {season, weeks} ->
      weeks
      |> Map.to_list()
      |> Enum.each(fn {week, map} ->
        IO.puts(file, "#{season} #{week} - #{map["title"]}, #{inspect(map["colors"])}")
      end)
    end)

    file |> File.close()
  end

  def readings(season, wk, yr), do: identity()[season][wk][yr]

  def readings(date) do
    {season, wk, yr, _} = Lityear.to_season(date)
    # readings(season, wk, yr)
    r = identity()[season][wk]
    if r |> is_nil, do: IEx.pry()

    %{
      gs: r[yr].gs,
      ot: r[yr].ot,
      ps: r[yr].ps,
      nt: r[yr].nt,
      season: season,
      week: wk,
      title: r["title"],
      colors: r["colors"],
      collect: Collects.get(season, wk),
      leaflet: Leaflets.for_this_sunday(season, wk, yr)
    }
  end

  def colors(date) do
    {season, wk, _yr, _} = Lityear.to_season(date)
    identity()[season][wk]["colors"]
  end

  def holy_day(title, date), do: eu_map({"redLetter", title, "a", date})
  def next_sunday, do: Timex.now(@tz) |> next_sunday
  def next_sunday(date), do: date |> Lityear.next_sunday() |> _sunday
  def this_sunday(date), do: date |> Lityear.to_season() |> _sunday
  def last_sunday(), do: Timex.now(@tz) |> last_sunday
  def last_sunday(date), do: date |> Lityear.last_sunday() |> _sunday
  def from_now, do: Timex.now(@tz) |> this_sunday

  def holy_day_color("epiphany"), do: identity()["theEpiphany"]["1"]["colors"]
  def holy_day_color("christmas"), do: identity()["christmasDay"]["1"]["colors"]
  def holy_day_color("christmasEve"), do: identity()["christmasDay"]["1"]["colors"]
  def holy_day_color("advent4ChristmasEve"), do: identity()["advent"]["4"]["colors"]
  def holy_day_color("christmasDay"), do: identity()["christmasDay"]["1"]["colors"]
  def holy_day_color(title), do: identity()["redLetter"][title]["colors"]

  def holy_day_title("epiphany"), do: identity()["theEpiphany"]["1"]["title"]
  def holy_day_title("christmasEve"), do: "Christmas Eve"
  def holy_day_title("advent4ChristmasEve"), do: "Advent 4 - Christmas Eve"
  def holy_day_title("christmasDay"), do: "Christmas Day"
  def holy_day_title(title), do: identity()["redLetter"][title]["title"]

  def _sunday({season, wk, yr, sunday}), do: eu_map({season, wk, yr, sunday})

  #  defp eu_map(nil, _date), do: IEx.pry
  defp eu_map({season, wk, yr, sunday}) do
    if identity()[season][wk]["colors"] == nil, do: IEx.pry()

    identity()[season][wk][yr]
    |> add_ids
    |> Map.merge(%{
      date: sunday |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY}"),
      season: season,
      week: wk,
      title: identity()[season][wk]["title"],
      colors: identity()[season][wk]["colors"],
      collect: Collects.get(season, wk),
      leaflet: Leaflets.for_this_sunday(season, wk, yr)
    })
  end

  def lesson(date, section, ver) do
    eu_today(date)[section |> String.to_atom()]
    |> BibleText.lesson_with_body(ver)
  end

  def namedReadings(season, wk) do
    identity()[season][wk]["a"]
    |> add_ids
    |> Map.merge(%{
      date: namedDayDate(season, wk) |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY}"),
      season: season,
      week: wk,
      title: identity()[season][wk]["title"]
    })
  end

  def add_ids(map) do
    map
    |> Map.update(:ot, [], fn el -> _add_ids_for("ot", el) end)
    |> Map.update(:ps, [], fn el -> _add_ids_for("ps", el) end)
    |> Map.update(:nt, [], fn el -> _add_ids_for("nt", el) end)
    |> Map.update(:gs, [], fn el -> _add_ids_for("gs", el) end)
  end

  defp _add_ids_for(_section, []), do: []

  defp _add_ids_for(section, list) do
    list |> Enum.map(fn el -> _add_this_id(section, el) end)
  end

  defp _add_this_id(section, map) do
    if map |> Map.has_key?(:read) do
      map |> Map.put_new(:id, Regex.replace(~r/[\s\.\:\,]/, map.read, "_"))
    else
      map
    end
    |> Map.put_new(:section, section)
    |> Map.put_new(:body, "")
    |> Map.put_new(:show, false)
    |> Map.put_new(:show_fn, true)
    |> Map.put_new(:show_vn, true)
    |> Map.put_new(:version, "")
  end

  def eu_today(date) do
    # if date is redletter, use those readings
    # but if date is sunday, use those sunday readings
    # otherwise use last_sunday 
    r = readings(date)

    %{
      # but it could be redletter
      ofType: "sunday",
      # was r.date - huh?
      date: date |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY}"),
      season: r.season,
      week: r.week,
      title: r.title,
      show: true,
      colors: r.colors,
      collect: r.collect,
      ot: r.ot,
      ps: r.ps,
      nt: r.nt,
      gs: r.gs,
      leaflet: r.leaflet,
      sectionUpdate: %{section: "", version: "", ref: ""}
    }

    # now load up the text bodies
  end

  def collect_today(date), do: readings(date).collect

  def reading_map(date) do
    r = readings(date)

    %{
      title: r.title,
      ot: r.ot |> Enum.map(& &1.read),
      ps: r.ps |> Enum.map(& &1.read),
      nt: r.nt |> Enum.map(& &1.read),
      gs: r.gs |> Enum.map(& &1.read),
      leaflet: Leaflets.for_this_date(date)
    }
  end

  def eu_body(date, versions_map \\ %{ps: "BCP", ot: "ESV", nt: "ESV", gs: "ESV"}) do
    eu = eu_today(date)

    [:ot, :ps, :nt, :gs]
    |> Enum.reduce(eu, fn r, acc ->
      acc |> Map.put(r, BibleText.lesson_with_body(eu[r], versions_map[r]))
    end)
  end

  def formatted_date(d), do: d |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY}")

  def build do
    # to whom it may concern...
    # I came to the conclusion that maintaining the lectionary as code
    # was just as easy - maybe more so - than a formatted file that needed to be parsed
    # change the following at your peril
    %{
      "advent" => %{
        "1" => %{
          "title" => "The First Sunday in Advent",
          "colors" => ["violet", "blue"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 2:1-5"}],
            ps: [%{style: "req", read: "Psalm 122"}],
            nt: [%{style: "req", read: "Rom 13:8-14"}],
            gs: [%{style: "req", read: "Mt 24:29-44"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 64:1-9a"}],
            ps: [%{style: "req", read: "Psalm 80"}, %{style: "alt", read: "Psalm 80:1-7"}],
            nt: [%{style: "req", read: "1 Cor 1:1-9"}],
            gs: [%{style: "req", read: "Mk 13:24-37"}]
          },
          "c" => %{
            ot: [%{style: "opt", read: "Zech 14:1-2"}, %{style: "req", read: "Zech 14:3-9"}],
            ps: [%{style: "req", read: "Psalm 50"}, %{style: "alt", read: "Psalm 50:1-6"}],
            nt: [%{style: "req", read: "1 Thess 3:6-13"}],
            gs: [%{style: "req", read: "Lk 21:25-33"}]
          }
        },
        "2" => %{
          "title" => "The Second Sunday in Advent",
          "colors" => ["violet", "blue"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 11:1-10"}],
            ps: [%{style: "req", read: "Psalm 72:1-15"}, %{style: "opt", read: "Psalm 72:16-19"}],
            nt: [%{style: "req", read: "Rom 15:1-13"}],
            gs: [%{style: "req", read: "Mt 3:1-12"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 40:1-11"}],
            ps: [%{style: "req", read: "Psalm 85"}],
            nt: [%{style: "req", read: "2 Pet 3:8-18"}],
            gs: [%{style: "req", read: "Mk 1:1-8"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Mal 3:1-5"}],
            ps: [%{style: "req", read: "Psalm 126"}],
            nt: [%{style: "opt", read: "1 Cor 4:1-7"}, %{style: "req", read: "1 Cor 4:8-21"}],
            gs: [%{style: "req", read: "Lk 3:1-6"}]
          }
        },
        "3" => %{
          "title" => "The Third Sunday in Advent",
          "colors" => ["rose", "violet", "blue"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 35:1-10"}],
            ps: [%{style: "req", read: "Psalm 146"}],
            nt: [%{style: "req", read: "James 5:7-12"}],
            gs: [%{style: "req", read: "Mt 11:2-19"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 65:17-25"}],
            ps: [%{style: "req", read: "Psalm 126"}],
            nt: [%{style: "req", read: "1 Thess 5:12-28"}],
            gs: [%{style: "req", read: "Jn 3:22-30"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Zeph 3:14-20"}],
            ps: [%{style: "req", read: "Psalm 85"}],
            nt: [%{style: "req", read: "Phil 4:4-9"}],
            gs: [%{style: "req", read: "Lk 3:7-20"}]
          }
        },
        "4" => %{
          "title" => "The Fourth Sunday in Advent",
          "colors" => ["violet", "blue"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 7:10-17"}],
            ps: [%{style: "req", read: "Psalm 24"}],
            nt: [%{style: "req", read: "Rom 1:1-7"}],
            gs: [%{style: "req", read: "Mt 1:18-25"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "2 Sam 7:1-17"}],
            ps: [%{style: "opt", read: "Psalm 132:1-7"}, %{style: "req", read: "Psalm 132:8-19"}],
            nt: [%{style: "req", read: "Rom 16:25-27"}],
            gs: [%{style: "req", read: "Lk 1:26-38"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Mic 5:2-5a"}],
            ps: [%{style: "req", read: "Psalm 80:1-7"}],
            nt: [%{style: "req", read: "Heb 10:1-10"}],
            gs: [%{style: "req", read: "Lk 1:39-56"}]
          }
        }
      },
      "christmasDay" => %{
        "1" => %{
          "title" => "Christmas Day I",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 9:1-7"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "Titus 2:11-14"}],
            gs: [%{style: "req", read: "Lk 2:1-14"}, %{style: "opt", read: "Lk 2:15-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 9:1-7"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "Titus 2:11-14"}],
            gs: [%{style: "req", read: "Lk 2:1-14"}, %{style: "opt", read: "Lk 2:15-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 9:1-7"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "Titus 2:11-14"}],
            gs: [%{style: "req", read: "Lk 2:1-14"}, %{style: "opt", read: "Lk 2:15-20"}]
          }
        },
        "2" => %{
          "title" => "Christmas Day II",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 62:6-12"}],
            ps: [%{style: "req", read: "Psalm 97"}],
            nt: [%{style: "req", read: "Titus 3:4-7"}],
            gs: [%{style: "opt", read: "Lk 2:1-14"}, %{style: "req", read: "Lk 2:15-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 62:6-12"}],
            ps: [%{style: "req", read: "Psalm 97"}],
            nt: [%{style: "req", read: "Titus 3:4-7"}],
            gs: [%{style: "opt", read: "Lk 2:1-14"}, %{style: "req", read: "Lk 2:15-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 62:6-12"}],
            ps: [%{style: "req", read: "Psalm 97"}],
            nt: [%{style: "req", read: "Titus 3:4-7"}],
            gs: [%{style: "opt", read: "Lk 2:1-14"}, %{style: "req", read: "Lk 2:15-20"}]
          }
        },
        "3" => %{
          "title" => "Christmas Day III",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 52:7-12"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "Heb 1:1-12"}],
            gs: [%{style: "req", read: "Jn 1:1-18"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 52:7-12"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "Heb 1:1-12"}],
            gs: [%{style: "req", read: "Jn 1:1-18"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 52:7-12"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "Heb 1:1-12"}],
            gs: [%{style: "req", read: "Jn 1:1-18"}]
          }
        }
      },
      "christmas" => %{
        "1" => %{
          "title" => "The First Sunday of Christmas",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 61:10-end, 62:1-5"}],
            ps: [%{style: "req", read: "Psalm 147:13-21"}],
            nt: [%{style: "req", read: "Gal 3:23-4:7"}],
            gs: [%{style: "req", read: "Jn 1:1-18"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 61:10-end, 62:1-5"}],
            ps: [%{style: "req", read: "Psalm 147:13-21"}],
            nt: [%{style: "req", read: "Gal 3:23-4:7"}],
            gs: [%{style: "req", read: "Jn 1:1-18"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 61:10-end, 62:1-5"}],
            ps: [%{style: "req", read: "Psalm 147:13-21"}],
            nt: [%{style: "req", read: "Gal 3:23-4:7"}],
            gs: [%{style: "req", read: "Jn 1:1-18"}]
          }
        },
        "2" => %{
          "title" => "The Second Sunday of Christmas",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Jer 31:7-14"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Eph 1:3-14"}],
            gs: [%{style: "req", read: "Lk 2:41-52"}, %{style: "alt", read: "Mt 2:1-12"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Jer 31:7-14"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Eph 1:3-14"}],
            gs: [%{style: "req", read: "Mt 2:13-23"}, %{style: "alt", read: "Mt 2:1-12"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 31:7-14"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Eph 1:3-14"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}, %{style: "alt", read: "Mt 2:1-12"}]
          }
        }
      },
      "holyName" => %{
        "1" => %{
          "title" => "Holy Name (January 1)",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 34:1-9"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [%{style: "req", read: "Rom 1:1-7"}],
            gs: [%{style: "req", read: "Lk 2:15-21"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ex 34:1-9"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [%{style: "req", read: "Rom 1:1-7"}],
            gs: [%{style: "req", read: "Lk 2:15-21"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 34:1-9"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [%{style: "req", read: "Rom 1:1-7"}],
            gs: [%{style: "req", read: "Lk 2:15-21"}]
          }
        }
      },
      "theEpiphany" => %{
        "1" => %{
          "title" => "The Epiphany (January 6)",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 60:1-9"}],
            ps: [%{style: "req", read: "Psalm 72"}, %{style: "alt", read: "Psalm 72:1-15"}],
            nt: [%{style: "req", read: "Eph 3:1-13"}],
            gs: [%{style: "req", read: "Mt 2:1-12"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 60:1-9"}],
            ps: [%{style: "req", read: "Psalm 72"}, %{style: "alt", read: "Psalm 72:1-11"}],
            nt: [%{style: "req", read: "Eph 3:1-13"}],
            gs: [%{style: "req", read: "Mt 2:1-12"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 60:1-9"}],
            ps: [%{style: "req", read: "Psalm 72"}, %{style: "alt", read: "Psalm 72:1-11"}],
            nt: [%{style: "req", read: "Eph 3:1-13"}],
            gs: [%{style: "req", read: "Mt 2:1-12"}]
          }
        }
      },
      "epiphany" => %{
        "0" => %{
          "title" => "The Epiphany (January 6)",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 60:1-9"}],
            ps: [%{style: "req", read: "Psalm 72"}, %{style: "alt", read: "Psalm 72:1-15"}],
            nt: [%{style: "req", read: "Eph 3:1-13"}],
            gs: [%{style: "req", read: "Mt 2:1-12"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 60:1-9"}],
            ps: [%{style: "req", read: "Psalm 72"}, %{style: "alt", read: "Psalm 72:1-11"}],
            nt: [%{style: "req", read: "Eph 3:1-13"}],
            gs: [%{style: "req", read: "Mt 2:1-12"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 60:1-9"}],
            ps: [%{style: "req", read: "Psalm 72"}, %{style: "alt", read: "Psalm 72:1-11"}],
            nt: [%{style: "req", read: "Eph 3:1-13"}],
            gs: [%{style: "req", read: "Mt 2:1-12"}]
          }
        },
        "1" => %{
          "title" => "The First Sunday of Epiphany [Baptism of our Lord]",
          "colors" => ["white", "gold"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 42:1-9"}],
            ps: [%{style: "req", read: "Psalm 89:1-29"}, %{style: "alt", read: "Psalm 89:20-29"}],
            nt: [%{style: "req", read: "Acts 10:34-38"}],
            gs: [%{style: "req", read: "Mt 3:13-17"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 42:1-9"}],
            ps: [%{style: "req", read: "Psalm 89:1-29"}, %{style: "alt", read: "Psalm 89:20-29"}],
            nt: [%{style: "req", read: "Acts 10:34-38"}],
            gs: [%{style: "req", read: "Mk 1:7-11"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 42:1-9"}],
            ps: [%{style: "req", read: "Psalm 89:1-29"}, %{style: "alt", read: "Psalm 89:20-29"}],
            nt: [%{style: "req", read: "Acts 10:34-38"}],
            gs: [%{style: "req", read: "Lk 3:15-22"}]
          }
        },
        "2" => %{
          "title" => "The Second Sunday of Epiphany",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 49:1-7"}],
            ps: [%{style: "req", read: "Psalm 40:1-10"}],
            nt: [%{style: "req", read: "1 Cor 1:1-9"}],
            gs: [%{style: "req", read: "Jn 1:29-42"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "1 Sam 3:1-20"}],
            ps: [%{style: "req", read: "Psalm 63:1-8"}, %{style: "opt", read: "Psalm 63:9-11"}],
            nt: [%{style: "req", read: "1 Cor 6:9-20"}],
            gs: [%{style: "req", read: "Jn 1:43-51"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 62:1-5"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "1 Cor 12:1-11"}],
            gs: [%{style: "req", read: "Jn 2:1-11"}]
          }
        },
        "3" => %{
          "title" => "The Third Sunday of Epiphany",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Amos 3:1-11"}],
            ps: [%{style: "req", read: "Psalm 139:1-16"}],
            nt: [%{style: "req", read: "1 Cor 1:10-17"}],
            gs: [%{style: "req", read: "Mt 4:12-22"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Jer 3:19-4:4"}],
            ps: [%{style: "req", read: "Psalm 130"}],
            nt: [%{style: "req", read: "1 Cor 7:17-24"}],
            gs: [%{style: "req", read: "Mk 1:14-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Neh 8:1-12"}],
            ps: [%{style: "req", read: "Psalm 113"}],
            nt: [%{style: "req", read: "1 Cor 12:12-27"}],
            gs: [%{style: "req", read: "Lk 4:14-21"}]
          }
        },
        "4" => %{
          "title" => "The Fourth Sunday of Epiphany",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Mic 6:1-8"}],
            ps: [%{style: "req", read: "Psalm 37:1-11"}],
            nt: [%{style: "req", read: "1 Cor 1:18-31"}],
            gs: [%{style: "req", read: "Mt 5:1-12"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 18:15-22"}],
            ps: [%{style: "req", read: "Psalm 111"}],
            nt: [%{style: "req", read: "1 Cor 8:1-13"}],
            gs: [%{style: "req", read: "Mk 1:21-28"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 1:4-10"}],
            ps: [%{style: "req", read: "Psalm 71:12-21"}],
            nt: [%{style: "req", read: "1 Cor 14:12-25"}],
            gs: [%{style: "req", read: "Lk 4:21-32"}]
          }
        },
        "5" => %{
          "title" => "The Fifth Sunday of Epiphany ",
          "colors" => ["green"],
          "a" => %{
            ot: [
              %{style: "opt", read: "Hab 3:1"},
              %{style: "req", read: "Hab 3:2-15"},
              %{style: "opt", read: "Hab 3:16-19"}
            ],
            ps: [%{style: "req", read: "Psalm 27"}],
            nt: [%{style: "req", read: "1 Cor 2:1-16"}],
            gs: [%{style: "req", read: "Mt 5:13-20"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "2 Kings 4:8-21"},
              %{style: "opt", read: "2 Kings 4:22-31"},
              %{style: "req", read: "2 Kings 4:32-37"}
            ],
            ps: [%{style: "req", read: "Psalm 142"}],
            nt: [%{style: "req", read: "1 Cor 9:16-23"}],
            gs: [%{style: "req", read: "Mk 1:29-39"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Judg 6:11-24"}],
            ps: [%{style: "req", read: "Psalm 85"}],
            nt: [%{style: "req", read: "1 Cor 15:1-11"}],
            gs: [%{style: "req", read: "Lk 5:1-11"}]
          }
        },
        "6" => %{
          "title" => "The Sixth Sunday of Epiphany",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 15:11-20"}],
            ps: [%{style: "opt", read: "Psalm 119:1-8"}, %{style: "req", read: "Psalm 119:9-16"}],
            nt: [%{style: "req", read: "1 Cor 3:1-9"}],
            gs: [%{style: "req", read: "Mt 5:21-37"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "2 Kings 5:1-15ab"}],
            ps: [%{style: "req", read: "Psalm 42:1-7"}, %{style: "opt", read: "Psalm 42:8-15"}],
            nt: [%{style: "req", read: "1 Cor 9:24-27"}],
            gs: [%{style: "req", read: "Mk 1:40-45"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 17:5-10"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [%{style: "req", read: "1 Cor 15:12-20"}],
            gs: [%{style: "req", read: "Lk 6:17-26"}]
          }
        },
        "7" => %{
          "title" => "The Seventh Sunday of Epiphany",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Lev 19:1-2, 19:9-18"}],
            ps: [%{style: "req", read: "Psalm 71"}, %{style: "alt", read: "Psalm 71:12-24"}],
            nt: [%{style: "req", read: "1 Cor 3:10-23"}],
            gs: [%{style: "req", read: "Mt 5:38-48"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 43:18-25"}],
            ps: [%{style: "req", read: "Psalm 32"}],
            nt: [%{style: "req", read: "2 Cor 1:18-22"}],
            gs: [%{style: "req", read: "Mk 2:1-12"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 45:3-11, 45:21-28"}],
            ps: [%{style: "opt", read: "Psalm 37:1-7"}, %{style: "req", read: "Psalm 37:8-17"}],
            nt: [%{style: "req", read: "1 Cor 15:35-49"}],
            gs: [%{style: "req", read: "Lk 6:27-38"}]
          }
        },
        "8" => %{
          "title" => "The Second to Last Sunday after Epiphany [World Mission]",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 49:1-7"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Acts 1:1-8"}],
            gs: [%{style: "req", read: "Matthew 9:35-38"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 12:1-3"}],
            ps: [%{style: "req", read: "Psalm 86:8-13"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Mt 28:16-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 61:1-4"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "Rom 10:9-17"}],
            gs: [%{style: "req", read: "Jn 20:19-31"}]
          }
        },
        "9" => %{
          "title" => "The Last Sunday after Epiphany [Transfiguration]",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 24:12-18"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "Phil 3:7-14"}],
            gs: [%{style: "req", read: "Mt 17:1-9"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "1 Kings 19:9-18"}],
            ps: [%{style: "req", read: "Psalm 27"}],
            nt: [%{style: "req", read: "2 Pet 1:13-21"}],
            gs: [%{style: "req", read: "Mk 9:2-9"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 34:29-35"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "1 Cor 12:27-13:13"}],
            gs: [%{style: "req", read: "Lk 9:28-36"}]
          }
        }
      },
      "presentation" => %{
        "1" => %{
          "title" => "The Presentation of Christ in the Temple (February 2)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Mal 3:1-4"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Heb 2:14-18"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Mal 3:1-4"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Heb 2:14-18"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Mal 3:1-4"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Heb 2:14-18"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}]
          }
        }
      },
      "ashWednesday" => %{
        "1" => %{
          "title" => "Ash Wednesday",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Joel 2:1-2, 2:12-17"}],
            ps: [%{style: "req", read: "Psalm 103"}, %{style: "alt", read: "Psalm 103:8-14"}],
            nt: [%{style: "req", read: "2 Cor 5:20-6:10"}],
            gs: [%{style: "req", read: "Mt 6:1-6, 6:16-18"}, %{style: "opt", read: "Mt 6:19-21"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Joel 2:1-2, 12-17"}],
            ps: [%{style: "req", read: "Psalm 103"}, %{style: "alt", read: "Psalm 103:8-14"}],
            nt: [%{style: "req", read: "2 Cor 5:20-6:10"}],
            gs: [%{style: "req", read: "Mt 6:1-6, 16-18"}, %{style: "opt", read: "Mt 6:19-21"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Joel 2:1-2, 2:12-17"}],
            ps: [%{style: "req", read: "Psalm 103"}, %{style: "alt", read: "Psalm 103:8-14"}],
            nt: [%{style: "req", read: "2 Cor 5:20-6:10"}],
            gs: [%{style: "req", read: "Mt 6:1-6, 6:16-18"}, %{style: "opt", read: "Mt 6:19-21"}]
          }
        }
      },
      "lent" => %{
        "1" => %{
          "title" => "The First Sunday in Lent",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Gen 2:4-9, 2:15-17, 2:25-end, 3:1-7"}],
            ps: [%{style: "req", read: "Psalm 51"}, %{style: "alt", read: "Psalm 51:1-13"}],
            nt: [%{style: "req", read: "Rom 5:12-19"}, %{style: "opt", read: "Rom 5:20-21"}],
            gs: [%{style: "req", read: "Mt 4:1-11"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 9:8-17"}],
            ps: [%{style: "req", read: "Psalm 25"}, %{style: "alt", read: "Psalm 25:3-9"}],
            nt: [%{style: "req", read: "1 Pet 3:18-22"}],
            gs: [%{style: "req", read: "Mk 1:9-13"}]
          },
          "c" => %{
            ot: [%{style: "opt", read: "Deut 26:1-4"}, %{style: "req", read: "Deut 26:5-11"}],
            ps: [%{style: "req", read: "Psalm 91"}, %{style: "alt", read: "Psalm 91:9-16"}],
            nt: [%{style: "req", read: "Rom 10:4-13"}],
            gs: [%{style: "req", read: "Lk 4:1-13"}]
          }
        },
        "2" => %{
          "title" => "The Second Sunday in Lent",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Gen 12:1-9"}],
            ps: [%{style: "req", read: "Psalm 33:12-22"}],
            nt: [
              %{style: "req", read: "Rom 4:1-5"},
              %{style: "opt", read: "Rom 4:6-12"},
              %{style: "req", read: "Rom 4:13-17"}
            ],
            gs: [%{style: "req", read: "Jn 3:1-16"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 22:1-14"}],
            ps: [%{style: "req", read: "Psalm 16"}, %{style: "alt", read: "Psalm 16:5-11"}],
            nt: [%{style: "req", read: "Rom 8:31-39"}],
            gs: [%{style: "req", read: "Mk 8:31-38"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 15:1-12, 15:17-18"}],
            ps: [%{style: "req", read: "Psalm 27"}, %{style: "alt", read: "Psalm 27:10-18"}],
            nt: [%{style: "req", read: "Phil 3:17-4:1"}],
            gs: [%{style: "opt", read: "Lk 13:22-30"}, %{style: "req", read: "Lk 13:31-35"}]
          }
        },
        "3" => %{
          "title" => "The Third Sunday in Lent",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 17:1-7"}],
            ps: [%{style: "req", read: "Psalm 95"}],
            nt: [%{style: "req", read: "Rom 1:16-32"}],
            gs: [
              %{style: "req", read: "Jn 4:5-26"},
              %{style: "opt", read: "Jn 4:27-38"},
              %{style: "req", read: "Jn 4:39-42"}
            ]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ex 20:1-21"}],
            ps: [%{style: "req", read: "Psalm 19:7-14"}],
            nt: [%{style: "req", read: "Rom 7:12-25"}],
            gs: [%{style: "req", read: "Jn 2:13-22"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 3:1-15"}],
            ps: [%{style: "req", read: "Psalm 103"}, %{style: "alt", read: "Psalm 103:1-12"}],
            nt: [%{style: "req", read: "1 Cor 10:1-13"}],
            gs: [%{style: "req", read: "Lk 13:1-9"}]
          }
        },
        "4" => %{
          "title" => "The Fourth Sunday in Lent",
          "colors" => ["rose", "violet", "blue"],
          "a" => %{
            ot: [%{style: "req", read: "1 Sam 16:1-13"}],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "Eph 5:1-14"}],
            gs: [%{style: "req", read: "Jn 9:1-13, 9:28-38"}, %{style: "opt", read: "Jn 9:39-41"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "2 Chronicles 36:14-23"}],
            ps: [%{style: "req", read: "Psalm 122"}],
            nt: [%{style: "req", read: "Eph 2:4-10"}],
            gs: [%{style: "req", read: "Jn 6:1-15"}]
          },
          "c" => %{
            ot: [
              %{style: "opt", read: "Josh 4:19-24"},
              %{style: "req", read: "Josh 5:1"},
              %{style: "opt", read: "Josh 5:2-8"},
              %{style: "req", read: "Josh 5:9-12"}
            ],
            ps: [%{style: "req", read: "Psalm 34"}, %{style: "alt", read: "Psalm 34:1-8"}],
            nt: [%{style: "req", read: "2 Cor 5:17-21"}],
            gs: [%{style: "req", read: "Lk 15:11-32"}]
          }
        },
        "5" => %{
          "title" => "The Fifth Sunday in Lent",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Ezek 37:1-14"}],
            ps: [%{style: "req", read: "Psalm 130"}],
            nt: [%{style: "req", read: "Rom 6:15-23"}],
            gs: [%{style: "opt", read: "Jn 11:1-17"}, %{style: "req", read: "Jn 11:18-44"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Jer 31:31-34"}],
            ps: [%{style: "req", read: "Psalm 51"}, %{style: "alt", read: "Psalm 51:11-16"}],
            nt: [%{style: "opt", read: "Heb 4:14-16"}, %{style: "req", read: "Heb 5:1-10"}],
            gs: [%{style: "req", read: "Jn 12:20-33"}, %{style: "opt", read: "Jn 12:34-36"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 43:16-21"}],
            ps: [%{style: "req", read: "Psalm 126"}],
            nt: [%{style: "req", read: "Phil 3:7-16"}],
            gs: [%{style: "req", read: "Lk 20:9-19"}]
          }
        }
      },
      "palmSundayPalms" => %{
        "1" => %{
          "title" => "Palm Sunday: Liturgy of the Palms",
          "colors" => ["red"],
          "a" => %{
            ot: [],
            nt: [],
            gs: [%{style: "req", read: "Mt 21:1-11"}],
            ps: [%{style: "req", read: "Psalm 118:19-29"}]
          },
          "b" => %{
            ot: [],
            nt: [],
            gs: [%{style: "req", read: "Mk 11:1-11a"}],
            ps: [%{style: "req", read: "Psalm 118:19-29"}]
          },
          "c" => %{
            ot: [],
            nt: [],
            gs: [%{style: "req", read: "Lk 19:29-40"}],
            ps: [%{style: "req", read: "Psalm 118:19-29"}]
          }
        }
      },
      "palmSunday" => %{
        "1" => %{
          "title" => "Palm Sunday",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 52:13-end, 53:1-12"}],
            ps: [%{style: "req", read: "Psalm 22:1-21"}, %{style: "alt", read: "Psalm 22:1-11"}],
            nt: [%{style: "req", read: "Phil 2:5-11"}],
            gs: [
              %{style: "opt", read: "Mt 26:36-75"},
              %{style: "req", read: "Mt 27:1-54"},
              %{style: "opt", read: "Mt 27:55-66"}
            ]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 52:13-end, 53:1-12"}],
            ps: [%{style: "req", read: "Psalm 22:1-11"}, %{style: "alt", read: "Psalm 22:1-21"}],
            nt: [%{style: "req", read: "Phil 2:5-11"}],
            gs: [
              %{style: "opt", read: "Mk 14:32-72"},
              %{style: "req", read: "Mk 15:1-39"},
              %{style: "opt", read: "Mk 15:40-47"}
            ]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 52:13-end, 53:1-12"}],
            ps: [%{style: "req", read: "Psalm 22:1-11"}, %{style: "alt", read: "Psalm 22:1-21"}],
            nt: [%{style: "req", read: "Phil 2:5-11"}],
            gs: [
              %{style: "opt", read: "Lk 22:39-71"},
              %{style: "req", read: "Lk 23:1-49"},
              %{style: "opt", read: "Lk 23:50-56"}
            ]
          }
        }
      },
      "holyWeek" => %{
        "1" => %{
          "title" => "Monday in Holy Week",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 42:1-9"}],
            ps: [%{style: "req", read: "Psalm 36:5-10"}],
            nt: [%{style: "req", read: "Heb 11:39-12:3"}],
            gs: [%{style: "req", read: "Jn 12:1-11"}, %{style: "alt", read: "Mk 14:3-9"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 42:1-9"}],
            ps: [%{style: "req", read: "Psalm 36:5-10"}],
            nt: [%{style: "req", read: "Heb 11:39-12:3"}],
            gs: [%{style: "req", read: "Jn 12:1-11"}, %{style: "alt", read: "Mk 14:3-9"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 42:1-9"}],
            ps: [%{style: "req", read: "Psalm 36:5-10"}],
            nt: [%{style: "req", read: "Heb 11:39-12:3"}],
            gs: [%{style: "req", read: "Jn 12:1-11"}, %{style: "alt", read: "Mk 14:3-9"}]
          }
        },
        "2" => %{
          "title" => "Tuesday in Holy Week",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 49:1-6"}],
            ps: [%{style: "req", read: "Psalm 71:1-12"}],
            nt: [%{style: "req", read: "1 Cor 1:18-31"}],
            gs: [
              %{style: "req", read: "Jn 12:37-38, 12:42-50"},
              %{style: "alt", read: "Mk 11:15-19"}
            ]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 49:1-6"}],
            ps: [%{style: "req", read: "Psalm 71:1-12"}],
            nt: [%{style: "req", read: "1 Cor 1:18-31"}],
            gs: [
              %{style: "req", read: "Jn 12:37-38, 12:42-50"},
              %{style: "alt", read: "Mk 11:15-19"}
            ]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 49:1-6"}],
            ps: [%{style: "req", read: "Psalm 71:1-12"}],
            nt: [%{style: "req", read: "1 Cor 1:18-31"}],
            gs: [
              %{style: "req", read: "Jn 12:37-38, 12:42-50"},
              %{style: "alt", read: "Mk 11:15-19"}
            ]
          }
        },
        "3" => %{
          "title" => "Wednesday in Holy Week",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 50:4-9"}],
            ps: [%{style: "req", read: "Psalm 69:7-15"}, %{style: "req", read: "Psalm 69:22-23"}],
            nt: [%{style: "req", read: "Heb 9:11-28"}],
            gs: [%{style: "req", read: "Mt 26:1-5, 26:14-25"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 50:4-9"}],
            ps: [%{style: "req", read: "Psalm 69:7-15"}, %{style: "req", read: "Psalm 69:22-23"}],
            nt: [%{style: "req", read: "Heb 9:11-28"}],
            gs: [%{style: "req", read: "Mt 26:1-5, 26:14-25"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 50:4-9"}],
            ps: [%{style: "req", read: "Psalm 69:7-15"}, %{style: "req", read: "Psalm 69:22-23"}],
            nt: [%{style: "req", read: "Heb 9:11-28"}],
            gs: [%{style: "req", read: "Mt 26:1-5, 26:14-25"}]
          }
        },
        "4" => %{
          "title" => "Maundy Thursday",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 12:1-14"}],
            ps: [%{style: "req", read: "Psalm 78:14-25"}],
            nt: [
              %{style: "req", read: "1 Cor 11:23-26"},
              %{style: "opt", read: "1 Cor 11:27-34}]"}
            ],
            gs: [%{style: "req", read: "Jn 13:1-15"}, %{style: "alt", read: "Lk 22:14-30"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ex 12:1-14"}],
            ps: [%{style: "req", read: "Psalm 78:14-25"}],
            nt: [
              %{style: "req", read: "1 Cor 11:23-26"},
              %{style: "opt", read: "1 Cor 11:27-34}]"}
            ],
            gs: [%{style: "req", read: "Jn 13:1-15"}, %{style: "alt", read: "Lk 22:14-30"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 12:1-14"}],
            ps: [%{style: "req", read: "Psalm 78:14-25"}],
            nt: [
              %{style: "req", read: "1 Cor 11:23-26"},
              %{style: "opt", read: "1 Cor 11:27-34}]"}
            ],
            gs: [%{style: "req", read: "Jn 13:1-15"}, %{style: "alt", read: "Lk 22:14-30"}]
          }
        },
        "5" => %{
          "title" => "Good Friday ",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Gen 22:1-18"}],
            ps: [
              %{style: "req", read: "Psalm 22:1-11"},
              %{style: "opt", read: "Psalm 22:12-21"},
              %{style: "alt", read: "Psalm 40:1-14"},
              %{style: "alt", read: "Psalm 69:1-23"}
            ],
            nt: [%{style: "req", read: "Heb 10:1-25"}],
            gs: [%{style: "opt", read: "Jn 18:1-40"}, %{style: "req", read: "Jn 19:1-37"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 22:1-18"}],
            ps: [
              %{style: "req", read: "Psalm 22:1-11"},
              %{style: "opt", read: "Psalm 22:12-21"},
              %{style: "alt", read: "Psalm 40:1-14"},
              %{style: "alt", read: "Psalm 69:1-23"}
            ],
            nt: [%{style: "req", read: "Heb 10:1-25"}],
            gs: [%{style: "opt", read: "Jn 18:1-40"}, %{style: "req", read: "Jn 19:1-37"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 22:1-18"}],
            ps: [
              %{style: "req", read: "Psalm 22:1-11"},
              %{style: "opt", read: "Psalm 22:12-21"},
              %{style: "alt", read: "Psalm 40:1-14"},
              %{style: "alt", read: "Psalm 69:1-23"}
            ],
            nt: [%{style: "req", read: "Heb 10:1-25"}],
            gs: [%{style: "opt", read: "Jn 18:1-40"}, %{style: "req", read: "Jn 19:1-37"}]
          }
        },
        "6" => %{
          "title" => "Holy Saturday",
          "colors" => ["violet"],
          "a" => %{
            ot: [%{style: "req", read: "Job 14:1-17"}],
            ps: [%{style: "req", read: "Psalm 130"}, %{style: "alt", read: "Psalm 31:1-5"}],
            nt: [%{style: "req", read: "1 Pet 4:1-8"}],
            gs: [%{style: "req", read: "Mt 27:57-66"}, %{style: "alt", read: "Jn 19:38-42"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Job 14:1-17"}],
            ps: [%{style: "req", read: "Psalm 130"}, %{style: "alt", read: "Psalm 31:1-5"}],
            nt: [%{style: "req", read: "1 Pet 4:1-8"}],
            gs: [%{style: "req", read: "Mt 27:57-66"}, %{style: "alt", read: "Jn 19:38-42"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Job 14:1-17"}],
            ps: [%{style: "req", read: "Psalm 130"}, %{style: "alt", read: "Psalm 31:1-5"}],
            nt: [%{style: "req", read: "1 Pet 4:1-8"}],
            gs: [%{style: "req", read: "Mt 27:57-66"}, %{style: "alt", read: "Jn 19:38-42"}]
          }
        }
      },
      "easterDayVigil" => %{
        "1" => %{
          "title" => "The Great Vigil of Easter",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Genesis 1, 2:1-2"},
              %{style: "req", read: "Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13"},
              %{style: "req", read: "Genesis 22:1-18"},
              %{style: "req", read: "Exodus 14:10-end, 15:1"},
              %{style: "req", read: "Isaiah 4:2-6"},
              %{style: "req", read: "Isaiah 55:1-11"},
              %{style: "req", read: "Ezekiel 36:24-28"},
              %{style: "req", read: "Ezekiel 37:1-14"},
              %{style: "req", read: "Zephaniah 3:12-20"}
            ],
            ps: [],
            nt: [%{style: "req", read: "Romans 6:3-11"}],
            gs: [%{style: "req", read: "Matthew 28:1-10"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Genesis 1, 2:1-2"},
              %{style: "req", read: "Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13"},
              %{style: "req", read: "Genesis 22:1-18"},
              %{style: "req", read: "Exodus 14:10-end, 15:1"},
              %{style: "req", read: "Isaiah 4:2-6"},
              %{style: "req", read: "Isaiah 55:1-11"},
              %{style: "req", read: "Ezekiel 36:24-28"},
              %{style: "req", read: "Ezekiel 37:1-14"},
              %{style: "req", read: "Zephaniah 3:12-20"}
            ],
            ps: [],
            nt: [%{style: "req", read: "Romans 6:3-11"}],
            gs: [%{style: "req", read: "Matthew 28:1-10"}]
          },
          "c" => %{
            ot: [
              %{style: "req", read: "Genesis 1, 2:1-2"},
              %{style: "req", read: "Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13"},
              %{style: "req", read: "Genesis 22:1-18"},
              %{style: "req", read: "Exodus 14:10-end, 15:1"},
              %{style: "req", read: "Isaiah 4:2-6"},
              %{style: "req", read: "Isaiah 55:1-11"},
              %{style: "req", read: "Ezekiel 36:24-28"},
              %{style: "req", read: "Ezekiel 37:1-14"},
              %{style: "req", read: "Zephaniah 3:12-20"}
            ],
            ps: [],
            nt: [%{style: "req", read: "Romans 6:3-11"}],
            gs: [%{style: "req", read: "Matthew 28:1-10"}]
          }
        }
      },
      "easterDay" => %{
        "2" => %{
          "title" => "Easter Day: Early Service",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "alt", read: "Genesis 1, 2:1-2"},
              %{style: "alt", read: "Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13"},
              %{style: "alt", read: "Genesis 22:1-18"},
              %{style: "alt", read: "Exodus 14:10-end, 15:1"},
              %{style: "alt", read: "Isaiah 4:2-6"},
              %{style: "alt", read: "Isaiah 55:1-11"},
              %{style: "alt", read: "Ezekiel 36:24-28"},
              %{style: "alt", read: "Ezekiel 37:1-14"},
              %{style: "alt", read: "Zephaniah 3:12-20"}
            ],
            ps: [%{style: "req", read: "Psalm 114"}],
            nt: [%{style: "req", read: "Rom 6:3-11"}],
            gs: [%{style: "req", read: "Mt 28:1-10"}]
          },
          "b" => %{
            ot: [
              %{style: "alt", read: "Genesis 1, 2:1-2"},
              %{style: "alt", read: "Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13"},
              %{style: "alt", read: "Genesis 22:1-18"},
              %{style: "alt", read: "Exodus 14:10-end, 15:1"},
              %{style: "alt", read: "Isaiah 4:2-6"},
              %{style: "alt", read: "Isaiah 55:1-11"},
              %{style: "alt", read: "Ezekiel 36:24-28"},
              %{style: "alt", read: "Ezekiel 37:1-14"},
              %{style: "alt", read: "Zephaniah 3:12-20"}
            ],
            ps: [%{style: "req", read: "Psalm 114"}],
            nt: [%{style: "req", read: "Rom 6:3-11"}],
            gs: [%{style: "req", read: "Mt 28:1-10"}]
          },
          "c" => %{
            ot: [
              %{style: "alt", read: "Genesis 1, 2:1-2"},
              %{style: "alt", read: "Genesis 7:1-5, 7:11-18, 8:8-18, 9:8-13"},
              %{style: "alt", read: "Genesis 22:1-18"},
              %{style: "alt", read: "Exodus 14:10-end, 15:1"},
              %{style: "alt", read: "Isaiah 4:2-6"},
              %{style: "alt", read: "Isaiah 55:1-11"},
              %{style: "alt", read: "Ezekiel 36:24-28"},
              %{style: "alt", read: "Ezekiel 37:1-14"},
              %{style: "alt", read: "Zephaniah 3:12-20"}
            ],
            ps: [%{style: "req", read: "Psalm 114"}],
            nt: [%{style: "req", read: "Rom 6:3-11"}],
            gs: [%{style: "req", read: "Mt 28:1-10"}]
          }
        },
        "1" => %{
          "title" => "Easter Day: Principal Service",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Acts 10:34-43"},
              %{style: "alt", read: "Ex 14:10-14, 14:21-31"}
            ],
            ps: [
              %{style: "req", read: "Psalm 118:14-17"},
              %{style: "req", read: "Psalm 118:22-24"}
            ],
            nt: [%{style: "req", read: "Col 3:1-4"}, %{style: "alt", read: "Acts 10:34-43"}],
            gs: [
              %{style: "req", read: "Jn 20:1-10"},
              %{style: "opt", read: "Jn 20:11-18"},
              %{style: "alt", read: "Mt 28:1-10"}
            ]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 10:34-43"}, %{style: "alt", read: "Is 25:6-9"}],
            ps: [
              %{style: "req", read: "Psalm 118:14-17"},
              %{style: "req", read: "Psalm 118:22-24"}
            ],
            nt: [%{style: "req", read: "Col 3:1-4"}, %{style: "alt", read: "Acts 10:34-43"}],
            gs: [%{style: "req", read: "Mk 16:1-8"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 10:34-43"}, %{style: "alt", read: "Is 51:9-11"}],
            ps: [
              %{style: "req", read: "Psalm 118:14-17"},
              %{style: "req", read: "Psalm 118:22-24"}
            ],
            nt: [%{style: "req", read: "Col 3:1-4"}, %{style: "alt", read: "Acts 10:34-43"}],
            gs: [%{style: "req", read: "Lk 24:1-10"}]
          }
        },
        "3" => %{
          "title" => "Easter Day: Evening Service",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Dan 12:1-3"}],
            ps: [%{style: "req", read: "Psalm 136"}],
            nt: [%{style: "req", read: "1 Cor 5:6-8"}],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Dan 12:1-3"}],
            ps: [%{style: "req", read: "Psalm 136"}],
            nt: [%{style: "req", read: "1 Cor 5:6-8"}],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Dan 12:1-3"}],
            ps: [%{style: "req", read: "Psalm 136"}],
            nt: [%{style: "req", read: "1 Cor 5:6-8"}],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          }
        }
      },
      "easterWeek" => %{
        "1" => %{
          "title" => "Monday of Easter Week",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 2:14, 2:22-32"}],
            ps: [%{style: "req", read: "Psalm 16"}],
            nt: [],
            gs: [%{style: "req", read: "Mt 28:9-15"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 2:14, 2:22-32"}],
            ps: [%{style: "req", read: "Psalm 16"}],
            nt: [],
            gs: [%{style: "req", read: "Mt 28:9-15"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 2:14, 2:22-32"}],
            ps: [%{style: "req", read: "Psalm 16"}],
            nt: [],
            gs: [%{style: "req", read: "Mt 28:9-15"}]
          }
        },
        "2" => %{
          "title" => "Tuesday of Easter Week",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 2:14, 2:36-41"}],
            ps: [%{style: "req", read: "Psalm 33:18-22"}],
            nt: [],
            gs: [%{style: "req", read: "Jn 20:11-18"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 2:14, 2:36-41"}],
            ps: [%{style: "req", read: "Psalm 33:18-22"}],
            nt: [],
            gs: [%{style: "req", read: "Jn 20:11-18"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 2:14, 2:36-41"}],
            ps: [%{style: "req", read: "Psalm 33:18-22"}],
            nt: [],
            gs: [%{style: "req", read: "Jn 20:11-18"}]
          }
        },
        "3" => %{
          "title" => "Wednesday of Easter Week",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 3:1-10"}],
            ps: [%{style: "req", read: "Psalm 105:1-8"}],
            nt: [],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 3:1-10"}],
            ps: [%{style: "req", read: "Psalm 105:1-8"}],
            nt: [],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 3:1-10"}],
            ps: [%{style: "req", read: "Psalm 105:1-8"}],
            nt: [],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          }
        },
        "4" => %{
          "title" => "Thursday of Easter Week",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 3:11-26"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [],
            gs: [%{style: "req", read: "Lk 24:36-49"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 3:11-26"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [],
            gs: [%{style: "req", read: "Lk 24:36-49"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 3:11-26"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [],
            gs: [%{style: "req", read: "Lk 24:36-49"}]
          }
        },
        "5" => %{
          "title" => "Friday of Easter Week",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "1 Pet 1:3-9"}],
            ps: [%{style: "req", read: "Psalm 116:1-8"}],
            nt: [],
            gs: [%{style: "req", read: "Jn 21:1-14"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "1 Pet 1:3-9"}],
            ps: [%{style: "req", read: "Psalm 116:1-8"}],
            nt: [],
            gs: [%{style: "req", read: "Jn 21:1-14"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "1 Pet 1:3-9"}],
            ps: [%{style: "req", read: "Psalm 116:1-8"}],
            nt: [],
            gs: [%{style: "req", read: "Jn 21:1-14"}]
          }
        },
        "6" => %{
          "title" => "Saturday of Easter Week",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 4:1-22"}],
            ps: [%{style: "req", read: "Psalm 118:14-18"}],
            nt: [],
            gs: [%{style: "req", read: "Mk 16:9-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 4:1-22"}],
            ps: [%{style: "req", read: "Psalm 118:14-18"}],
            nt: [],
            gs: [%{style: "req", read: "Mk 16:9-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 4:1-22"}],
            ps: [%{style: "req", read: "Psalm 118:14-18"}],
            nt: [],
            gs: [%{style: "req", read: "Mk 16:9-20"}]
          }
        }
      },
      "easter" => %{
        "2" => %{
          "title" => "The Second Sunday of Easter",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Acts 3:12a, 3:13-15, 3:17-26"},
              %{style: "alt", read: "Gen 8:6-16, 9:8-16"}
            ],
            ps: [%{style: "req", read: "Psalm 111"}],
            nt: [%{style: "req", read: "1 Jn 5:1-5"}],
            gs: [%{style: "req", read: "Jn 20:19-31"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Acts 3:12a,  3:13-15, 3:17-26"},
              %{style: "alt", read: "Is 26:1-9, 26:19"}
            ],
            ps: [%{style: "req", read: "Psalm 111"}],
            nt: [%{style: "req", read: "1 Jn 5:1-5"}],
            gs: [%{style: "req", read: "Jn 20:19-31"}]
          },
          "c" => %{
            ot: [
              %{style: "req", read: "Acts 3:12a, 3:13-15 3:17-26"},
              %{style: "alt", read: "Job 42:1-6"}
            ],
            ps: [%{style: "req", read: "Psalm 111"}],
            nt: [%{style: "opt", read: "Rev 1:1-8"}, %{style: "req", read: "Rev 1:9-19"}],
            gs: [%{style: "req", read: "Jn 20:19-31"}]
          }
        },
        "3" => %{
          "title" => "The Third Sunday of Easter",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Acts 2:14a, 2:36-47"},
              %{style: "alt", read: "Is 43:1-12"}
            ],
            ps: [%{style: "req", read: "Psalm 116:10-17"}],
            nt: [%{style: "req", read: "1 Pet 1:13-25"}],
            gs: [%{style: "req", read: "Lk 24:13-35"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 4:5-14"}, %{style: "alt", read: "Mic 4:1-5"}],
            ps: [%{style: "req", read: "Psalm 98"}, %{style: "alt", read: "Psalm 98:1-5"}],
            nt: [%{style: "req", read: "1 Jn 1:1-2:2"}],
            gs: [%{style: "req", read: "Lk 24:36-49"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 9:1-19a"}, %{style: "alt", read: "Jer 32:36-41"}],
            ps: [%{style: "req", read: "Psalm 33"}, %{style: "alt", read: "Psalm 33:1-11"}],
            nt: [%{style: "opt", read: "Rev 5:1-5"}, %{style: "req", read: "Rev 5:6-14"}],
            gs: [%{style: "req", read: "Jn 21:1-14"}]
          }
        },
        "4" => %{
          "title" => "The Fourth Sunday of Easter [Good Shepherd]",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Acts 6:1-9, 7:2a, 7:51-60"},
              %{style: "opt", read: "Neh 9:1-3"},
              %{style: "req", read: "Neh 9:6-15"}
            ],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "1 Pet 2:13-25"}],
            gs: [%{style: "req", read: "Jn 10:1-10"}]
          },
          "b" => %{
            ot: [
              %{style: "opt", read: "Acts 4:23-31"},
              %{style: "req", read: "Acts 4:32-37"},
              %{style: "opt", read: "Ezek 34:1-10"}
            ],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "1 Jn 3:1-10"}],
            gs: [%{style: "req", read: "Jn 10:11-16"}]
          },
          "c" => %{
            ot: [
              %{style: "req", read: "Acts 13:14b-16, 13:26-39"},
              %{style: "opt", read: "Num 27:12-23"}
            ],
            ps: [%{style: "req", read: "Psalm 100"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 10:22-30"}]
          }
        },
        "5" => %{
          "title" => "The Fifth Sunday of Easter",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 17:1-15"}, %{style: "alt", read: "Deut 6:20-25"}],
            ps: [%{style: "req", read: "Psalm 66:1-11"}, %{style: "alt", read: "Psalm 66:1-8"}],
            nt: [%{style: "req", read: "1 Pet 2:1-12"}],
            gs: [%{style: "req", read: "Jn 14:1-14"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 8:26-40"}, %{style: "alt", read: "Deut 4:32-40"}],
            ps: [%{style: "req", read: "Psalm 66:1-11"}, %{style: "alt", read: "Psalm 66:1-8"}],
            nt: [%{style: "opt", read: "1 Jn 3:11-17"}, %{style: "req", read: "1 Jn 3:18-24"}],
            gs: [%{style: "req", read: "Jn 14:15-21"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 13:44-52"}, %{style: "alt", read: "Lev 19:1-2,9-18"}],
            ps: [%{style: "req", read: "Psalm 145"}, %{style: "alt", read: "Psalm 145:1-9"}],
            nt: [%{style: "req", read: "Rev 19:1-9"}],
            gs: [%{style: "req", read: "Jn 13:31-35"}]
          }
        },
        "6" => %{
          "title" => "The Sixth Sunday of Easter [Rogation Sunday]",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 17:22-34"}, %{style: "alt", read: "Is 41:17-20"}],
            ps: [%{style: "req", read: "Psalm 148"}, %{style: "alt", read: "Psalm 148:7-14"}],
            nt: [%{style: "req", read: "1 Pet 3:8-18"}],
            gs: [%{style: "req", read: "Jn 15:1-11"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Acts 11:19-30"},
              %{style: "alt", read: "Is 45:11-13, 45:18-19"},
              %{style: "opt", read: "Is 45:20-25"}
            ],
            ps: [
              %{style: "req", read: "Psalm 33"},
              %{style: "alt", read: "Psalm 33:1-8, 33:18-22"}
            ],
            nt: [%{style: "req", read: "1 Jn 4:7-21"}],
            gs: [%{style: "req", read: "Jn 15:9-17"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 14:8-18"}, %{style: "alt", read: "Joel 2:21-27"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Rev 21:1-4, 21:22-end, 22:1-5"}],
            gs: [%{style: "req", read: "Jn 14:21-29"}]
          }
        },
        "7" => %{
          "title" => "The Sunday after Ascension Day",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Acts 1:1-5"},
              %{style: "req", read: "Acts 1:6-14"},
              %{style: "alt", read: "Ezek 39:21-29"}
            ],
            ps: [%{style: "req", read: "Psalm 68:1-20"}, %{style: "alt", read: "Psalm 47"}],
            nt: [%{style: "req", read: "1 Pet 4:12-19"}],
            gs: [%{style: "req", read: "Jn 17:1-11"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Acts 1:15-26"},
              %{style: "alt", read: "Ex 28:1-4, 28:9-10, 28:29-30"}
            ],
            ps: [%{style: "req", read: "Psalm 68:1-20"}, %{style: "alt", read: "Psalm 47"}],
            nt: [%{style: "req", read: "1 Jn 5:6-15"}],
            gs: [%{style: "req", read: "Jn 17:11b-19"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 16:16-34"}, %{style: "alt", read: "1 Sam 12:19-24"}],
            ps: [%{style: "req", read: "Psalm 68:1-20"}, %{style: "alt", read: "Psalm 47"}],
            nt: [%{style: "req", read: "Rev 22:10-21"}],
            gs: [%{style: "req", read: "Jn 17:20-26"}]
          }
        }
      },
      "ascension" => %{
        "1" => %{
          "title" => "Ascension Day",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 1:1-11"}],
            ps: [%{style: "req", read: "Psalm 47"}, %{style: "alt", read: "Psalm 110:1-5"}],
            nt: [%{style: "req", read: "Eph 1:15-23"}],
            gs: [%{style: "req", read: "Lk 24:44-53"}, %{style: "alt", read: "Mk 16:9-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 1:1-11"}],
            ps: [%{style: "req", read: "Psalm 47"}, %{style: "alt", read: "Psalm 110:1-5"}],
            nt: [%{style: "req", read: "Eph 1:15-23"}],
            gs: [%{style: "req", read: "Lk 24:44-53"}, %{style: "alt", read: "Mk 16:9-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 1:1-11"}],
            ps: [%{style: "req", read: "Psalm 47"}, %{style: "alt", read: "Psalm 110:1-5"}],
            nt: [%{style: "req", read: "Eph 1:15-23"}],
            gs: [%{style: "req", read: "Lk 24:44-53"}, %{style: "alt", read: "Mk 16:9-20"}]
          }
        }
      },
      "pentecost" => %{
        "1" => %{
          "title" => "Pentecost ",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 2:1-11"}],
            ps: [
              %{style: "req", read: "Psalm 104:25-37"},
              %{style: "alt", read: "Psalm 104:25-32"}
            ],
            nt: [%{style: "req", read: "1 Cor 12:4-13"}],
            gs: [%{style: "req", read: "Jn 20:19-23"}, %{style: "alt", read: "Jn 14:8-17"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 2:1-11"}],
            ps: [
              %{style: "req", read: "Psalm 104:25-37"},
              %{style: "alt", read: "Psalm 104:25-32"}
            ],
            nt: [%{style: "req", read: "1 Cor 12:4-13"}],
            gs: [%{style: "req", read: "Jn 20:19-23"}, %{style: "alt", read: "Jn 14:8-17"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 2:1-11"}],
            ps: [
              %{style: "req", read: "Psalm 104:25-37"},
              %{style: "alt", read: "Psalm 104:25-32"}
            ],
            nt: [%{style: "req", read: "1 Cor 12:4-13"}],
            gs: [%{style: "req", read: "Jn 20:19-23"}, %{style: "alt", read: "Jn 14:8-17"}]
          }
        }
      },
      "trinity" => %{
        "1" => %{
          "title" => "Trinity Sunday",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Gen 1:1-end, 2:1-3"}],
            ps: [%{style: "req", read: "Psalm 150"}],
            nt: [%{style: "req", read: "2 Cor 13:5-14"}],
            gs: [%{style: "req", read: "Mt 28:16-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ex 3:1-6"}],
            ps: [%{style: "req", read: "Psalm 93"}],
            nt: [%{style: "req", read: "Rom 8:12-17"}],
            gs: [%{style: "req", read: "Jn 3:1-16"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 6:1-7"}],
            ps: [%{style: "req", read: "Psalm 29"}],
            nt: [%{style: "req", read: "Rev 4:1-11"}],
            gs: [%{style: "opt", read: "Jn 16:5-11"}, %{style: "req", read: "Jn 16:12-15"}]
          }
        }
      },
      "pentecostWeekday" => %{
        "1" => %{
          "title" => "Weekdays following the Sunday Closest to May 11",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 15:11-20"}],
            ps: [%{style: "req", read: "Psalm 119:1-16"}],
            nt: [%{style: "req", read: "1 Cor 3:1-9"}],
            gs: [%{style: "req", read: "Mt 5:21-37"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "2 Kings 5:1-15ab"}],
            ps: [%{style: "req", read: "Psalm 42"}],
            nt: [%{style: "req", read: "1 Cor 9:24-27"}],
            gs: [%{style: "req", read: "Mk 1:40-45"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 17:5-10"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [%{style: "req", read: "1 Cor 15:12-20"}],
            gs: [%{style: "req", read: "Lk 6:17-26"}]
          }
        },
        "2" => %{
          "title" => "Weekdays following the Sunday Closest to May 18",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Lev 19:1-2, 19:9-18"}],
            ps: [%{style: "req", read: "Psalm 71"}, %{style: "alt", read: "Psalm 71:12-24"}],
            nt: [%{style: "req", read: "1 Cor 3:10-23"}],
            gs: [%{style: "req", read: "Mt 5:38-48"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 43:18-25"}],
            ps: [%{style: "req", read: "Psalm 32"}],
            nt: [%{style: "req", read: "2 Cor 1:18-22"}],
            gs: [%{style: "req", read: "Mk 2:1-12"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 45:3-11, 45:21-28"}],
            ps: [%{style: "opt", read: "Psalm 37:1-7"}, %{style: "req", read: "Psalm 37:8-17"}],
            nt: [%{style: "req", read: "1 Cor 15:35-49"}],
            gs: [%{style: "req", read: "Lk 6:27-38"}]
          }
        }
      },
      "proper" => %{
        "1" => %{
          "title" => "Sunday Closest to May 11",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 49:1-7"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Acts 1:1-8"}],
            gs: [%{style: "req", read: "Matthew 9:35-38"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 12:1-3"}],
            ps: [%{style: "req", read: "Psalm 86:8-13"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Mt 28:16-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 61:1-4"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "Rom 10:9-17"}],
            gs: [%{style: "req", read: "Jn 20:19-31"}]
          }
        },
        "2" => %{
          "title" => "Sunday Closest to May 18",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 24:12-18"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "Phil 3:7-14"}],
            gs: [%{style: "req", read: "Mt 17:1-9"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "1 Kings 19:9-18"}],
            ps: [%{style: "req", read: "Psalm 27"}],
            nt: [%{style: "req", read: "2 Pet 1:13-21"}],
            gs: [%{style: "req", read: "Mk 9:2-9"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 34:29-35"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "1 Cor 12:27-13:13"}],
            gs: [%{style: "req", read: "Lk 9:28-36"}]
          }
        },
        "3" => %{
          "title" => "Sunday Closest to May 25",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 49:8-18"}],
            ps: [%{style: "req", read: "Psalm 62"}],
            nt: [%{style: "req", read: "1 Cor 4:1-13"}],
            gs: [%{style: "req", read: "Mt 6:24-34"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Hos 2:14-23"}],
            ps: [%{style: "req", read: "Psalm 103"}, %{style: "alt", read: "Psalm 103:1-14"}],
            nt: [%{style: "req", read: "2 Cor 3:4-18"}],
            gs: [%{style: "req", read: "Mk 2:18-22"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 7:1-15"}],
            ps: [%{style: "req", read: "Psalm 92"}],
            nt: [%{style: "req", read: "1 Cor 15:50-58"}],
            gs: [%{style: "req", read: "Lk 6:39-49"}]
          }
        },
        "4" => %{
          "title" => "Sunday Closest to June 1",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 11:18-32"}],
            ps: [%{style: "req", read: "Psalm 31"}, %{style: "alt", read: "Psalm 31:16-27"}],
            nt: [%{style: "req", read: "Rom 3:21-31"}],
            gs: [%{style: "req", read: "Mt 7:21-27"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 5:6-21"}],
            ps: [%{style: "req", read: "Psalm 81:1-11"}, %{style: "opt", read: "Psalm 81:12-17"}],
            nt: [%{style: "req", read: "2 Cor 4:1-12"}],
            gs: [%{style: "req", read: "Mk 2:23-28"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "1 Kings 8:22-30, 41-43"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "Gal 1:1-10"}],
            gs: [%{style: "req", read: "Lk 7:1-10"}]
          }
        },
        "5" => %{
          "title" => "Sunday Closest to June 8",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Hos 5:15-end, 6:1-6"}],
            ps: [%{style: "req", read: "Psalm 50"}],
            nt: [%{style: "req", read: "Rom 4:13-18"}],
            gs: [%{style: "req", read: "Mt 9:9-13"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 3:1-21"}],
            ps: [%{style: "req", read: "Psalm 130"}],
            nt: [%{style: "req", read: "2 Cor 4:13-18"}],
            gs: [%{style: "req", read: "Mk 3:20-35"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "1 Kings 17:17-24"}],
            ps: [%{style: "req", read: "Psalm 30"}],
            nt: [%{style: "req", read: "Gal 1:11-24"}],
            gs: [%{style: "req", read: "Lk 7:11-17"}]
          }
        },
        "6" => %{
          "title" => "Sunday Closest to June 15",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 19:1-8"}],
            ps: [%{style: "req", read: "Psalm 100"}],
            nt: [%{style: "req", read: "Rom 5:1-11"}],
            gs: [%{style: "req", read: "Mt 9:35-10:15"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Ezek 31:1-6"},
              %{style: "opt", read: "Ezek 31:7-9"},
              %{style: "req", read: "Ezek 31:10-14"}
            ],
            ps: [%{style: "req", read: "Psalm 92"}],
            nt: [%{style: "req", read: "2 Cor 5:1-10"}],
            gs: [%{style: "req", read: "Mk 4:26-34"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "2 Sam 11:26-end, 12:1-15"}],
            ps: [%{style: "req", read: "Psalm 32:1-6"}, %{style: "opt", read: "Psalm 32:7-12"}],
            nt: [%{style: "req", read: "Gal 2:11-21"}],
            gs: [%{style: "req", read: "Lk 7:36-50"}]
          }
        },
        "7" => %{
          "title" => "Sunday Closest to June 22",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Jer 20:7-13"}],
            ps: [%{style: "req", read: "Psalm 69:1-16"}, %{style: "opt", read: "Psalm 69:17-19"}],
            nt: [%{style: "req", read: "Rom 5:15b-19"}],
            gs: [%{style: "req", read: "Mt 10:16-33"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Job 38:1-11"},
              %{style: "opt", read: "Job 38:12-15"},
              %{style: "req", read: "Job 38:16-18"}
            ],
            ps: [
              %{style: "req", read: "Psalm 107:1-3"},
              %{style: "opt", read: "Psalm 107:4-22"},
              %{style: "req", read: "Psalm 107:23-32"}
            ],
            nt: [%{style: "req", read: "2 Cor 5:14-21"}],
            gs: [%{style: "req", read: "Mk 4:35-41"}, %{style: "opt", read: "Mk 5:1-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Zech 12:8-10, 13:1"}],
            ps: [%{style: "req", read: "Psalm 63"}],
            nt: [%{style: "req", read: "Gal 3:23-29"}],
            gs: [%{style: "req", read: "Lk 9:18-24"}]
          }
        },
        "8" => %{
          "title" => "Sunday Closest to June 29",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 2:10-17"}],
            ps: [%{style: "req", read: "Psalm 89:1-18"}],
            nt: [%{style: "req", read: "Rom 6:1-11"}],
            gs: [%{style: "req", read: "Mt 10:34-42"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 15:7-11"}],
            ps: [%{style: "req", read: "Psalm 112"}],
            nt: [%{style: "req", read: "2 Cor 8:1-15"}],
            gs: [%{style: "req", read: "Mk 5:22-24, 5:35b-43"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "1 Kings 19:15-21"}],
            ps: [%{style: "req", read: "Psalm 16"}],
            nt: [%{style: "req", read: "Gal 5:1, 5:13-25"}],
            gs: [%{style: "req", read: "Lk 9:51-62"}]
          }
        },
        "9" => %{
          "title" => "Sunday Closest to July 6",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Zech 9:9-12"}],
            ps: [
              %{style: "req", read: "Psalm 145:1-13"},
              %{style: "opt", read: "Psalm 145:14-21"}
            ],
            nt: [%{style: "req", read: "Rom 7:21-8:6"}],
            gs: [%{style: "req", read: "Mt 11:25-30"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ezek 2:1-7"}],
            ps: [%{style: "req", read: "Psalm 123"}],
            nt: [%{style: "req", read: "2 Cor 12:2-10"}],
            gs: [%{style: "req", read: "Mk 6:1-6"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 66:10-16"}],
            ps: [%{style: "req", read: "Psalm 66"}, %{style: "alt", read: "Psalm 66:1-8"}],
            nt: [%{style: "opt", read: "Gal 6:1-5"}, %{style: "req", read: "Gal 6:6-18"}],
            gs: [%{style: "req", read: "Lk 10:1-20"}]
          }
        },
        "10" => %{
          "title" => "Sunday Closest to July 13",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 55"}],
            ps: [%{style: "req", read: "Psalm 65"}],
            nt: [%{style: "req", read: "Rom 8:7-17"}],
            gs: [%{style: "req", read: "Mt 13:1-9, 13:18-23"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Amos 7:7-15"}],
            ps: [%{style: "req", read: "Psalm 85"}],
            nt: [%{style: "req", read: "Eph 1:1-14"}],
            gs: [%{style: "req", read: "Mark 6:7-13"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 30:9-14"}],
            ps: [%{style: "req", read: "Psalm 25:1-14"}, %{style: "opt", read: "Psalm 25:15-21"}],
            nt: [%{style: "req", read: "Col 1:1-14"}],
            gs: [%{style: "req", read: "Lk 10:25-37"}]
          }
        },
        "11" => %{
          "title" => "Sunday Closest to July 20",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Wis 12:13, 12:16-19"}],
            ps: [%{style: "req", read: "Psalm 86"}],
            nt: [%{style: "req", read: "Rom 8:18-25"}],
            gs: [%{style: "req", read: "Mt 13:24-30, 13:34-43"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 57:14-21"}],
            ps: [%{style: "req", read: "Psalm 22:23-32"}],
            nt: [%{style: "req", read: "Eph 2:11-22"}],
            gs: [%{style: "req", read: "Mark 6:30-44"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 18:1-14"}],
            ps: [%{style: "req", read: "Psalm 15"}],
            nt: [%{style: "req", read: "Col 1:21-29"}],
            gs: [%{style: "req", read: "Lk 10:38-42"}]
          }
        },
        "12" => %{
          "title" => "Sunday Closest to July 27",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "1 Kings 3:3-14"}],
            ps: [%{style: "req", read: "Psalm 119:121-136"}],
            nt: [%{style: "req", read: "Rom 8:26-34"}],
            gs: [%{style: "req", read: "Mt 13:31-33, 13:44-50"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "2 Kings 2:1-15"}],
            ps: [%{style: "req", read: "Psalm 114"}],
            nt: [%{style: "req", read: "Eph 4:1-16"}],
            gs: [%{style: "req", read: "Mark 6:45-52"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 18:20-33"}],
            ps: [%{style: "req", read: "Psalm 138"}],
            nt: [%{style: "req", read: "Col 2:6-15"}],
            gs: [%{style: "req", read: "Lk 11:1-13"}]
          }
        },
        "13" => %{
          "title" => "Sunday Closest to August 3",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Neh 9:16-21"}],
            ps: [%{style: "opt", read: "Psalm 78:1-12"}, %{style: "req", read: "Psalm 78:13-25"}],
            nt: [%{style: "req", read: "Rom 8:35-39"}],
            gs: [%{style: "req", read: "Mt 14:13-21"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Ex 16:2-4"},
              %{style: "opt", read: "Ex 16:5-8"},
              %{style: "req", read: "Ex 16:9-15"}
            ],
            ps: [%{style: "req", read: "Psalm 78:1-13"}, %{style: "opt", read: "Psalm 78:14-25"}],
            nt: [%{style: "req", read: "Eph 4:17-25"}],
            gs: [%{style: "req", read: "Jn 6:24-35"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Eccl 1:12-end, 2:1-11"}],
            ps: [%{style: "req", read: "Psalm 49:1-12"}, %{style: "opt", read: "Psalm 49:13-20"}],
            nt: [%{style: "req", read: "Col 3:5-17"}],
            gs: [%{style: "req", read: "Lk 12:13-21"}]
          }
        },
        "14" => %{
          "title" => "Sunday Closest to August 10",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Jon 2:1-10"}],
            ps: [%{style: "req", read: "Psalm 29"}],
            nt: [%{style: "req", read: "Rom 9:1-5"}],
            gs: [%{style: "req", read: "Mt 14:22-33"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 8:1-10"}],
            ps: [
              %{style: "opt", read: "Psalm 34:1-7"},
              %{style: "req", read: "Psalm 34:8-15"},
              %{style: "opt", read: "Psalm 34:16-22"}
            ],
            nt: [%{style: "req", read: "Eph 4:25-5:2"}],
            gs: [%{style: "req", read: "Jn 6:37-51"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 15:1-6"}],
            ps: [%{style: "opt", read: "Psalm 33:1-9"}, %{style: "req", read: "Psalm 33:10-21"}],
            nt: [%{style: "req", read: "Heb 11:1-16"}],
            gs: [%{style: "req", read: "Lk 12:32-40"}]
          }
        },
        "15" => %{
          "title" => "Sunday Closest to August 17",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 56:1-8"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Rom 11:13-24"}],
            gs: [%{style: "req", read: "Mt 15:21-28"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Prov 9:1-6"}],
            ps: [%{style: "req", read: "Psalm 147"}],
            nt: [%{style: "req", read: "Eph 5:15-20"}],
            gs: [%{style: "req", read: "Jn 6:53-59"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 23:23-29"}],
            ps: [%{style: "req", read: "Psalm 82"}],
            nt: [%{style: "req", read: "Heb 12:1-14"}],
            gs: [%{style: "req", read: "Lk 12:49-56"}]
          }
        },
        "16" => %{
          "title" => "Sunday Closest to August 24",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 51:1-6"}],
            ps: [%{style: "req", read: "Psalm 138"}],
            nt: [%{style: "req", read: "Rom 11:25-36"}],
            gs: [%{style: "req", read: "Mt 16:13-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Josh 24:1-2a, 24:14-25"}],
            ps: [%{style: "req", read: "Psalm 16"}],
            nt: [%{style: "req", read: "Eph 5:21-33"}],
            gs: [%{style: "req", read: "Jn 6:60-69"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 28:14-22"}],
            ps: [%{style: "req", read: "Psalm 46"}],
            nt: [%{style: "opt", read: "Heb 12:15-17"}, %{style: "req", read: "Heb 12:18-29"}],
            gs: [%{style: "req", read: "Lk 13:22-30"}]
          }
        },
        "17" => %{
          "title" => "Sunday Closest to August 31",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Jer 15:15-21"}],
            ps: [%{style: "req", read: "Psalm 26"}],
            nt: [%{style: "req", read: "Rom 12:1-8"}],
            gs: [%{style: "req", read: "Mt 16:21-27"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 4:1-9"}],
            ps: [%{style: "req", read: "Psalm 15"}],
            nt: [%{style: "req", read: "Eph 6:10-20"}],
            gs: [%{style: "req", read: "Mk 7:1-23"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 10:7-18"}],
            ps: [%{style: "req", read: "Psalm 112"}],
            nt: [%{style: "req", read: "Heb 13:1-8"}],
            gs: [%{style: "req", read: "Lk 14:1, 7-14"}]
          }
        },
        "18" => %{
          "title" => "Sunday Closest to September 7",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ezek 33:1-11"}],
            ps: [%{style: "req", read: "Psalm 119:33-48"}],
            nt: [%{style: "req", read: "Rom 12:9-21"}],
            gs: [%{style: "req", read: "Mt 18:15-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 35:4-7a"}],
            ps: [%{style: "req", read: "Psalm 146"}],
            nt: [%{style: "req", read: "James 1:17-27"}],
            gs: [%{style: "req", read: "Mk 7:31-37"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 30:15-20"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [
              %{style: "opt", read: "Philemon 1-3"},
              %{style: "req", read: "Philemon 4-21"},
              %{style: "opt", read: "Philemon 22-25"}
            ],
            gs: [%{style: "req", read: "Lk 14:25-33"}]
          }
        },
        "19" => %{
          "title" => "Sunday Closest to September 14",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 27:30-end, 28:1-7"}],
            ps: [%{style: "req", read: "Psalm 103"}, %{style: "alt", read: "Psalm 103:1-14"}],
            nt: [%{style: "req", read: "Rom 14:5-12"}],
            gs: [%{style: "req", read: "Mt 18:21-35"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 50:4-9"}],
            ps: [%{style: "req", read: "Psalm 116:1-9"}, %{style: "opt", read: "Psalm 116:10-19"}],
            nt: [%{style: "req", read: "James 2:1-18"}],
            gs: [%{style: "req", read: "Mk 9:14-29"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 32:1,7-14"}],
            ps: [%{style: "req", read: "Psalm 51:1-17"}],
            nt: [%{style: "req", read: "1 Tim 1:12-17"}],
            gs: [%{style: "req", read: "Lk 15:1-10"}]
          }
        },
        "20" => %{
          "title" => "Sunday Closest to September 21",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Jonah 3:10-4:11"}],
            ps: [
              %{style: "opt", read: "Psalm 145:1-13"},
              %{style: "req", read: "Psalm 145:14-21"}
            ],
            nt: [%{style: "req", read: "Phil 1:21-27"}],
            gs: [%{style: "req", read: "Mt 20:1-16"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Wis 1:16-2:1, 2:12-22"}],
            ps: [%{style: "req", read: "Psalm 54"}],
            nt: [%{style: "req", read: "James 3:16-end, 4:1-6"}],
            gs: [%{style: "req", read: "Mk 9:30-37"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Amos 8:4-12"}],
            ps: [%{style: "req", read: "Psalm 138"}],
            nt: [%{style: "req", read: "1 Tim 2:1-7"}, %{style: "opt", read: "1 Tim 2:8-15"}],
            gs: [%{style: "req", read: "Lk 16:1-13"}]
          }
        },
        "21" => %{
          "title" => "Sunday Closest to September 28",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ezek 18:1-4, 18:25-32"}],
            ps: [%{style: "req", read: "Psalm 25:1-14"}, %{style: "opt", read: "Psalm 25:15-21"}],
            nt: [%{style: "req", read: "Phil 2:1-13"}],
            gs: [%{style: "req", read: "Mt 21:28-32"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Num 11:4-6, 11:10-17, 11:24-29"}],
            ps: [%{style: "opt", read: "Psalm 19:1-6"}, %{style: "req", read: "Psalm 19:7-14"}],
            nt: [
              %{style: "req", read: "James 4:7-12"},
              %{style: "opt", read: "James 4:13-end, 5:1-6"}
            ],
            gs: [%{style: "req", read: "Mk 9:38-48"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Amos 6:1-7"}],
            ps: [%{style: "req", read: "Psalm 146"}],
            nt: [%{style: "req", read: "1 Tim 6:11-19"}],
            gs: [%{style: "req", read: "Lk 16:19-31"}]
          }
        },
        "22" => %{
          "title" => "Sunday Closest to October 5",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 5:1-7"}],
            ps: [%{style: "opt", read: "Psalm 80:1-6"}, %{style: "req", read: "Psalm 80:7-19"}],
            nt: [%{style: "req", read: "Phil 3:14-21"}],
            gs: [%{style: "req", read: "Mt 21:33-44"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 2:18-24"}],
            ps: [%{style: "req", read: "Psalm 8"}],
            nt: [%{style: "opt", read: "Heb 2:1-8"}, %{style: "req", read: "Heb 2:9-18"}],
            gs: [%{style: "req", read: "Mk 10:2-9"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Hab 1:1-13, 2:1-4"}],
            ps: [%{style: "req", read: "Psalm 37:1-17"}],
            nt: [%{style: "req", read: "2 Tim 1:1-14"}],
            gs: [%{style: "req", read: "Lk 17:5-10"}]
          }
        },
        "23" => %{
          "title" => "Sunday Closest to October 12",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 25:1-9"}],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "Phil 4:4-13"}],
            gs: [%{style: "req", read: "Mt 22:1-14"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Amos 5:6-15"}],
            ps: [%{style: "req", read: "Psalm 90:1-12"}, %{style: "opt", read: "Psalm 90:13-17"}],
            nt: [%{style: "req", read: "Heb 3:1-6"}],
            gs: [%{style: "req", read: "Mk 10:17-31"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ruth 1:1-19a"}],
            ps: [%{style: "req", read: "Psalm 113"}],
            nt: [%{style: "req", read: "2 Tim 2:1-15"}],
            gs: [%{style: "req", read: "Lk 17:11-19"}]
          }
        },
        "24" => %{
          "title" => "Sunday Closest to October 19",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 45:1-7"}],
            ps: [%{style: "req", read: "Psalm 96"}],
            nt: [%{style: "req", read: "1 Thess 1:1-10"}],
            gs: [%{style: "req", read: "Mt 22:15-22"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 53:4-12"}],
            ps: [%{style: "req", read: "Psalm 91"}],
            nt: [%{style: "req", read: "Heb 4:12-16"}],
            gs: [%{style: "req", read: "Mk 10:35-45"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 32:3-8, 32:22-30"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "2 Tim 3:14-end, 4:1-5"}],
            gs: [%{style: "req", read: "Lk 18:1-8"}]
          }
        },
        "25" => %{
          "title" => "Sunday Closest to October 26",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 22:21-27"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [%{style: "req", read: "1 Thess 2:1-8"}],
            gs: [%{style: "req", read: "Mt 22:34-46"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 59:9-20"}],
            ps: [%{style: "req", read: "Psalm 13"}],
            nt: [%{style: "req", read: "Heb 5:11-end, 6:1-12"}],
            gs: [%{style: "req", read: "Mk 10:46-52"}]
          },
          "c" => %{
            ot: [
              %{style: "opt", read: "Jer 14:1-6"},
              %{style: "req", read: "Jer 14:7-10, 14:19-22,"}
            ],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "2 Tim 4:6-18"}],
            gs: [%{style: "req", read: "Lk 18:9-14"}]
          }
        },
        "26" => %{
          "title" => "Sunday Closest to November 2",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Mic 3:5-12"}],
            ps: [%{style: "req", read: "Psalm 43"}],
            nt: [%{style: "req", read: "1 Thess 2:9-20"}],
            gs: [%{style: "req", read: "Mt 23:1-12"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 6:1-9"}],
            ps: [%{style: "req", read: "Psalm 119:1-16"}],
            nt: [%{style: "req", read: "Heb 7:23-28"}],
            gs: [%{style: "req", read: "Mk 12:28-34"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 1:10-20"}],
            ps: [%{style: "req", read: "Psalm 32"}],
            nt: [%{style: "req", read: "2 Thess 1:1-12"}],
            gs: [%{style: "req", read: "Lk 19:1-10"}]
          }
        },
        "27" => %{
          "title" => "Sunday Closest to November 9",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Amos 5:18-24"}],
            ps: [%{style: "req", read: "Psalm 70"}],
            nt: [%{style: "req", read: "1 Thess 4:13-18"}],
            gs: [%{style: "req", read: "Mt 25:1-13"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "1 Kings 17:8-16"}],
            ps: [%{style: "req", read: "Psalm 146"}],
            nt: [%{style: "req", read: "Heb 9:24-28"}],
            gs: [%{style: "req", read: "Mk 12:38-44"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Job 19:23-27a"}],
            ps: [%{style: "req", read: "Psalm 17"}],
            nt: [%{style: "req", read: "2 Thess 2:13-end, 3:1-5"}],
            gs: [%{style: "req", read: "Lk 20:27-38"}]
          }
        },
        "28" => %{
          "title" => "Sunday Closest to November 16",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Zeph 1:7, 1:12-18"}],
            ps: [%{style: "req", read: "Psalm 90:1-12"}, %{style: "opt", read: "Psalm 90:13-17"}],
            nt: [%{style: "req", read: "1 Thess 5:1-10"}],
            gs: [%{style: "req", read: "Mt 25:14-30"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Dan 12:1-4a"}, %{style: "opt", read: "Dan 12:4b-13"}],
            ps: [%{style: "req", read: "Psalm 16"}],
            nt: [%{style: "req", read: "Heb 10:31-39"}],
            gs: [%{style: "req", read: "Mk 13:14-23"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Mal 3:13-end, 4:1-6"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "2 Thess 3:6-16"}],
            gs: [%{style: "req", read: "Lk 21:5-19"}]
          }
        },
        "29" => %{
          "title" => "Sunday Closest to November 23 (Christ the King)",
          "colors" => ["green"],
          "a" => %{
            ot: [%{style: "req", read: "Ezek 34:11-20"}],
            ps: [%{style: "req", read: "Psalm 95"}],
            nt: [%{style: "req", read: "1 Cor 15:20-28"}],
            gs: [%{style: "req", read: "Mt 25:31-46"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Dan 7:9-14"}],
            ps: [%{style: "req", read: "Psalm 93"}],
            nt: [%{style: "req", read: "Rev 1:1-8"}],
            gs: [%{style: "req", read: "Jn 18:33-37"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 23:1-6"}],
            ps: [%{style: "req", read: "Psalm 46"}],
            nt: [%{style: "req", read: "Col 1:11-20"}],
            gs: [%{style: "req", read: "Lk 23:35-43"}]
          }
        }
      },
      "allSaints" => %{
        "1" => %{
          "title" => "All Saints' Day (November 1)",
          "colors" => ["white"],
          "a" => %{
            ot: [
              %{style: "req", read: "Ecclesiasticus 44:1-14"},
              %{style: "alt", read: "Rev 7:9-17"}
            ],
            ps: [%{style: "req", read: "Psalm 149"}],
            nt: [
              %{style: "req", read: "Rev 7:9-17"},
              %{style: "alt-opt", read: "Eph 1:11-14"},
              %{style: "alt-req", read: "Eph 1:15-23"}
            ],
            gs: [
              %{style: "req", read: "Mt 5:1-12"},
              %{style: "alt", read: "Lk 6:20-26"},
              %{style: "alt-opt", read: "Lk 6:27-36"}
            ]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Ecclesiasticus 44:1-14"},
              %{style: "alt", read: "Rev 7:9-17"}
            ],
            ps: [%{style: "req", read: "Psalm 149"}],
            nt: [
              %{style: "req", read: "Rev 7:9-17"},
              %{style: "alt-opt", read: "Eph 1:11-14"},
              %{style: "alt", read: "Eph 1:15-23"}
            ],
            gs: [
              %{style: "req", read: "Mt 5:1-12"},
              %{style: "alt", read: "Lk 6:20-26"},
              %{style: "alt-opt", read: "Lk 6:27-36"}
            ]
          },
          "c" => %{
            ot: [
              %{style: "req", read: "Ecclesiasticus 44:1-14"},
              %{style: "alt", read: "Rev 7:9-17"}
            ],
            ps: [%{style: "req", read: "Psalm 149"}],
            nt: [
              %{style: "req", read: "Rev 7:9-17"},
              %{style: "alt-opt", read: "Eph 1:11-14"},
              %{style: "alt", read: "Eph 1:15-23"}
            ],
            gs: [
              %{style: "req", read: "Mt 5:1-12"},
              %{style: "alt", read: "Lk 6:20-26"},
              %{style: "alt-opt", read: "Lk 6:27-36"}
            ]
          }
        }
      },
      "redLetter" => %{
        "stAndrew" => %{
          "title" => "St. Andrew (November 30)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 30:11-14"}],
            ps: [%{style: "req", read: "Psalm 19"}, %{style: "alt", read: "Psalm 19:1-6"}],
            nt: [%{style: "req", read: "Rom 10:8b-18"}],
            gs: [%{style: "req", read: "Mt 4:18-22"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 30:11-14"}],
            ps: [%{style: "req", read: "Psalm 19"}, %{style: "alt", read: "Psalm 19:1-6"}],
            nt: [%{style: "req", read: "Rom 10:8b-18"}],
            gs: [%{style: "req", read: "Mt 4:18-22"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 30:11-14"}],
            ps: [%{style: "req", read: "Psalm 19"}, %{style: "alt", read: "Psalm 19:1-6"}],
            nt: [%{style: "req", read: "Rom 10:8b-18"}],
            gs: [%{style: "req", read: "Mt 4:18-22"}]
          }
        },
        "stThomas" => %{
          "title" => "St. Thomas (December 21)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Hab 2:1-4"}],
            ps: [%{style: "req", read: "Psalm 126"}],
            nt: [%{style: "req", read: "Heb 10:35-end, 11:1"}],
            gs: [%{style: "req", read: "Jn 20:19-29"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Hab 2:1-4"}],
            ps: [%{style: "req", read: "Psalm 126"}],
            nt: [%{style: "req", read: "Heb 10:35-end, 11:1"}],
            gs: [%{style: "req", read: "Jn 20:19-29"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Hab 2:1-4"}],
            ps: [%{style: "req", read: "Psalm 126"}],
            nt: [%{style: "req", read: "Heb 10:35-end, 11:1"}],
            gs: [%{style: "req", read: "Jn 20:19-29"}]
          }
        },
        "stStephen" => %{
          "title" => "St. Stephen (December 26)",
          "colors" => ["red"],
          "a" => %{
            ot: [
              %{style: "req", read: "Jer 26:1-9"},
              %{style: "opt", read: "Jer 26:10-11"},
              %{style: "req", read: "Jer 26:12-15"}
            ],
            ps: [%{style: "req", read: "Psalm 31:1-5"}, %{style: "opt", read: "Psalm 31:6-24"}],
            nt: [%{style: "req", read: "Acts 6:8-7:2a 6:51-60"}],
            gs: [%{style: "req", read: "Mt 23:29-39"}]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Jer 26:1-9"},
              %{style: "opt", read: "Jer 26:10-11"},
              %{style: "req", read: "Jer 26:12-15"}
            ],
            ps: [%{style: "req", read: "Psalm 31:1-5"}, %{style: "opt", read: "Psalm 31:6-24"}],
            nt: [%{style: "req", read: "Acts 6:8-7:2a 6:51-60"}],
            gs: [%{style: "req", read: "Mt 23:29-39"}]
          },
          "c" => %{
            ot: [
              %{style: "req", read: "Jer 26:1-9"},
              %{style: "opt", read: "Jer 26:10-11"},
              %{style: "req", read: "Jer 26:12-15"}
            ],
            ps: [%{style: "req", read: "Psalm 31:1-5"}, %{style: "opt", read: "Psalm 31:6-24"}],
            nt: [%{style: "req", read: "Acts 6:8-7:2a 6:51-60"}],
            gs: [%{style: "req", read: "Mt 23:29-39"}]
          }
        },
        "stJohn" => %{
          "title" => "St. John (December 27)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 33:18-23"}],
            ps: [
              %{style: "req", read: "Psalm 92:1-4"},
              %{style: "opt", read: "Psalm 92:5-10"},
              %{style: "req", read: "Psalm 92:1-14"}
            ],
            nt: [%{style: "req", read: "1 Jn 1"}],
            gs: [%{style: "req", read: "Jn 21:9-25"}, %{style: "alt", read: "Jn 1:1-18"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ex 33:18-23"}],
            ps: [
              %{style: "req", read: "Psalm 92:1-4"},
              %{style: "opt", read: "Psalm 92:5-10"},
              %{style: "req", read: "Psalm 92:11-14"}
            ],
            nt: [%{style: "req", read: "1 Jn 1"}],
            gs: [%{style: "req", read: "Jn 21:9-25"}, %{style: "alt", read: "Jn 1:1-18"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 33:18-23"}],
            ps: [
              %{style: "req", read: "Psalm 92:1-4"},
              %{style: "opt", read: "Psalm 92:5-10"},
              %{style: "req", read: "Psalm 92:11-14"}
            ],
            nt: [%{style: "req", read: "1 Jn 1"}],
            gs: [%{style: "req", read: "Jn 21:9-25"}, %{style: "alt", read: "Jn 1:1-18"}]
          }
        },
        "holyInnocents" => %{
          "title" => "Holy Innocents (December 28)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Jer 31:15-17"}],
            ps: [%{style: "req", read: "Psalm 124"}],
            nt: [%{style: "req", read: "Rev 21:1-7"}],
            gs: [%{style: "req", read: "Mt 2:13-18"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Jer 31:15-17"}],
            ps: [%{style: "req", read: "Psalm 124"}],
            nt: [%{style: "req", read: "Rev 21:1-7"}],
            gs: [%{style: "req", read: "Mt 2:13-18"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 31:15-17"}],
            ps: [%{style: "req", read: "Psalm 124"}],
            nt: [%{style: "req", read: "Rev 21:1-7"}],
            gs: [%{style: "req", read: "Mt 2:13-18"}]
          }
        },
        "confessionOfStPeter" => %{
          "title" => "Confession of St. Peter (January 18)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 4:8-13"}],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "1 Pet 5:1-11"}],
            gs: [%{style: "req", read: "Mt 16:13-19"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 4:8-13"}],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "1 Pet 5:1-11"}],
            gs: [%{style: "req", read: "Mt 16:13-19"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 4:8-13"}],
            ps: [%{style: "req", read: "Psalm 23"}],
            nt: [%{style: "req", read: "1 Pet 5:1-11"}],
            gs: [%{style: "req", read: "Mt 16:13-19"}]
          }
        },
        "conversionOfStPaul" => %{
          "title" => "Conversion of St. Paul (January 25)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 26:9-21"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Gal 1:11-24"}],
            gs: [%{style: "req", read: "Mt 10:16-25"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 26:9-21"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Gal 1:11-24"}],
            gs: [%{style: "req", read: "Mt 10:16-25"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 26:9-21"}],
            ps: [%{style: "req", read: "Psalm 67"}],
            nt: [%{style: "req", read: "Gal 1:11-24"}],
            gs: [%{style: "req", read: "Mt 10:16-25"}]
          }
        },
        "presentation" => %{
          "title" => "The Presentation of Christ in the Temple (February 2)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Mal 3:1-4"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Heb 2:14-18"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Mal 3:1-4"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Heb 2:14-18"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Mal 3:1-4"}],
            ps: [%{style: "req", read: "Psalm 84"}],
            nt: [%{style: "req", read: "Heb 2:14-18"}],
            gs: [%{style: "req", read: "Lk 2:22-40"}]
          }
        },
        "stMatthias" => %{
          "title" => "St. Matthias (February 24)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 1:15-26"}],
            ps: [%{style: "req", read: "Psalm 15"}],
            nt: [%{style: "req", read: "Phil 3:12-21"}],
            gs: [%{style: "req", read: "Jn 15:1-16"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 1:15-26"}],
            ps: [%{style: "req", read: "Psalm 15"}],
            nt: [%{style: "req", read: "Phil 3:12-21"}],
            gs: [%{style: "req", read: "Jn 15:1-16"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 1:15-26"}],
            ps: [%{style: "req", read: "Psalm 15"}],
            nt: [%{style: "req", read: "Phil 3:12-21"}],
            gs: [%{style: "req", read: "Jn 15:1-16"}]
          }
        },
        "stJoseph" => %{
          "title" => "St. Joseph (March 19)",
          "colors" => ["white", "blue"],
          "a" => %{
            ot: [%{style: "req", read: "2 Sam 7:4, 7:8-16"}],
            ps: [
              %{style: "req", read: "Psalm 89:1-4"},
              %{style: "opt", read: "Psalm 89:5-18"},
              %{style: "req", read: "Psalm 89:19-29"}
            ],
            nt: [%{style: "req", read: "Rom 4:13-18"}],
            gs: [%{style: "req", read: "Lk 2:41-52"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "2 Sam 7:4, 7:8-16"}],
            ps: [
              %{style: "req", read: "Psalm 89:1-4"},
              %{style: "opt", read: "Psalm 89:5-18"},
              %{style: "req", read: "Psalm 89:19-29"}
            ],
            nt: [%{style: "req", read: "Rom 4:13-18"}],
            gs: [%{style: "req", read: "Lk 2:41-52"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "2 Sam 7:4, 7:8-16"}],
            ps: [
              %{style: "req", read: "Psalm 89:1-4"},
              %{style: "opt", read: "Psalm 89:5-18"},
              %{style: "req", read: "Psalm 89:19-29"}
            ],
            nt: [%{style: "req", read: "Rom 4:13-18"}],
            gs: [%{style: "req", read: "Lk 2:41-52"}]
          }
        },
        "annunciation" => %{
          "title" => "The Annunciation (March 25)",
          "colors" => ["white", "blue"],
          # canticle 3 & 15 are the same aren't they?
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 7:10-14"}],
            # ,%{style: "opt", read: "Canticle 15"}],
            ps: [%{style: "req", read: "Psalm 40:1-11"}, %{style: "alt", read: "Canticle 3"}],
            nt: [%{style: "req", read: "Heb 10:5-10"}],
            gs: [%{style: "req", read: "Lk 1:26-38"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 7:10-14"}],
            # ,%{style: "opt", read: "Canticle 15"}],
            ps: [%{style: "req", read: "Psalm 40:1-11"}, %{style: "alt", read: "Canticle 3"}],
            nt: [%{style: "req", read: "Heb 10:5-10"}],
            gs: [%{style: "req", read: "Lk 1:26-38"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 7:10-14"}],
            # ,%{style: "opt", read: "Canticle 15"}],
            ps: [%{style: "req", read: "Psalm 40:1-11"}, %{style: "alt", read: "Canticle 3"}],
            nt: [%{style: "req", read: "Heb 10:5-10"}],
            gs: [%{style: "req", read: "Lk 1:26-38"}]
          }
        },
        "stMark" => %{
          "title" => "St. Mark (April 25)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 52:7-10"}],
            ps: [%{style: "req", read: "Psalm 2"}],
            nt: [%{style: "req", read: "Eph 4:7-8, 4:11-16"}],
            gs: [%{style: "req", read: "Mk 16:15-20"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 52:7-10"}],
            ps: [%{style: "req", read: "Psalm 2"}],
            nt: [%{style: "req", read: "Eph 4:7-8, 4:11-16"}],
            gs: [%{style: "req", read: "Mk 16:15-20"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 52:7-10"}],
            ps: [%{style: "req", read: "Psalm 2"}],
            nt: [%{style: "req", read: "Eph 4:7-8, 4:11-16"}],
            gs: [%{style: "req", read: "Mk 16:15-20"}]
          }
        },
        "stsPhilipAndJames" => %{
          "title" => "St. Philip St. James (May 1)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 30:18-21"}],
            ps: [%{style: "req", read: "Psalm 119:33-40"}],
            nt: [%{style: "req", read: "2 Cor 4:1-7"}],
            gs: [%{style: "req", read: "Jn 14:6-14"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 30:18-21"}],
            ps: [%{style: "req", read: "Psalm 119:33-40"}],
            nt: [%{style: "req", read: "2 Cor 4:1-7"}],
            gs: [%{style: "req", read: "Jn 14:6-14"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 30:18-21"}],
            ps: [%{style: "req", read: "Psalm 119:33-40"}],
            nt: [%{style: "req", read: "2 Cor 4:1-7"}],
            gs: [%{style: "req", read: "Jn 14:6-14"}]
          }
        },
        "visitation" => %{
          "title" => "The Visitation (May 31)",
          "colors" => ["blue", "white"],
          "a" => %{
            ot: [%{style: "req", read: "Zeph 3:14-18"}],
            ps: [%{style: "req", read: "Psalm 113"}, %{style: "alt", read: "Canticle 9"}],
            nt: [%{style: "req", read: "Col 3:12-17"}],
            gs: [%{style: "req", read: "Lk 1:39-56"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Zeph 3:14-18"}],
            ps: [%{style: "req", read: "Psalm 113"}, %{style: "alt", read: "Canticle 9"}],
            nt: [%{style: "req", read: "Col 3:12-17"}],
            gs: [%{style: "req", read: "Lk 1:39-56"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Zeph 3:14-18"}],
            ps: [%{style: "req", read: "Psalm 113"}, %{style: "alt", read: "Canticle 9"}],
            nt: [%{style: "req", read: "Col 3:12-17"}],
            gs: [%{style: "req", read: "Lk 1:39-56"}]
          }
        },
        "stBarnabas" => %{
          "title" => "St. Barnabas (June 11)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 42:5-12"}],
            ps: [%{style: "req", read: "Psalm 112"}],
            nt: [%{style: "req", read: "Acts 11:19-30, 13:1-3"}],
            gs: [%{style: "req", read: "Mt 10:7-16"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 42:5-12"}],
            ps: [%{style: "req", read: "Psalm 112"}],
            nt: [%{style: "req", read: "Acts 11:19-30, 13:1-3"}],
            gs: [%{style: "req", read: "Mt 10:7-16"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 42:5-12"}],
            ps: [%{style: "req", read: "Psalm 112"}],
            nt: [%{style: "req", read: "Acts 11:19-30, 13:1-3"}],
            gs: [%{style: "req", read: "Mt 10:7-16"}]
          }
        },
        "nativityOfJohnTheBaptist" => %{
          "title" => "Nativity of St. John the Baptist (June 24)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 40:1-11"}],
            ps: [%{style: "req", read: "Psalm 85:7-13"}],
            nt: [%{style: "req", read: "Acts 13:14b-26"}],
            gs: [%{style: "req", read: "Lk 1:57-80"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 40:1-11"}],
            ps: [%{style: "req", read: "Psalm 85:7-13"}],
            nt: [%{style: "req", read: "Acts 13:14b-26"}],
            gs: [%{style: "req", read: "Lk 1:57-80"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 40:1-11"}],
            ps: [%{style: "req", read: "Psalm 85:7-13"}],
            nt: [%{style: "req", read: "Acts 13:14b-26"}],
            gs: [%{style: "req", read: "Lk 1:57-80"}]
          }
        },
        "stPeterAndPaul" => %{
          "title" => "St. Peter St. Paul (June 29)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Ezek 34:11-16"}],
            ps: [%{style: "req", read: "Psalm 87"}],
            nt: [%{style: "req", read: "2 Tim 4:1-8"}],
            gs: [%{style: "req", read: "Jn 21:15-19"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ezek 34:11-16"}],
            ps: [%{style: "req", read: "Psalm 87"}],
            nt: [%{style: "req", read: "2 Tim 4:1-8"}],
            gs: [%{style: "req", read: "Jn 21:15-19"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ezek 34:11-16"}],
            ps: [%{style: "req", read: "Psalm 87"}],
            nt: [%{style: "req", read: "2 Tim 4:1-8"}],
            gs: [%{style: "req", read: "Jn 21:15-19"}]
          }
        },
        "dominion" => %{
          "title" => "Dominion Day (July 1)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 6:1-15"}],
            ps: [%{style: "req", read: "Psalm 145"}],
            nt: [%{style: "req", read: "1 Peter 2:1-6"}],
            gs: [%{style: "req", read: "Matt 22:16-21"}, %{style: "alt", read: "Matt 25:14-30"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 6:1-15"}],
            ps: [%{style: "req", read: "Psalm 145"}],
            nt: [%{style: "req", read: "1 Peter 2:1-6"}],
            gs: [%{style: "req", read: "Matt 22:16-21"}, %{style: "alt", read: "Matt 25:14-30"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 6:1-15"}],
            ps: [%{style: "req", read: "Psalm 145"}],
            nt: [%{style: "req", read: "1 Peter 2:1-6"}],
            gs: [%{style: "req", read: "Matt 22:16-21"}, %{style: "alt", read: "Matt 25:14-30"}]
          }
        },
        "independence" => %{
          "title" => "Independence Day (July 4)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 10:17-21"}],
            ps: [%{style: "req", read: "Psalm 145"}],
            nt: [%{style: "req", read: "Heb 11:8-16"}],
            gs: [%{style: "req", read: "Mt 5:43-48"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 10:17-21"}],
            ps: [%{style: "req", read: "Psalm 145"}],
            nt: [%{style: "req", read: "Heb 11:8-16"}],
            gs: [%{style: "req", read: "Mt 5:43-48"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 10:17-21"}],
            ps: [%{style: "req", read: "Psalm 145"}],
            nt: [%{style: "req", read: "Heb 11:8-16"}],
            gs: [%{style: "req", read: "Mt 5:43-48"}]
          }
        },
        "stMaryMagdalene" => %{
          "title" => "St. Mary Magdalene (July 22)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Judith 9:1, 11-14"}],
            ps: [%{style: "req", read: "Psalm 42:1-7"}, %{style: "opt", read: "Psalm 42:8-15"}],
            nt: [%{style: "req", read: "2 Cor 5:14-20a"}],
            gs: [%{style: "req", read: "Jn 20:11-18"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Judith 9:1, 11-14"}],
            ps: [%{style: "req", read: "Psalm 42:1-7"}, %{style: "opt", read: "Psalm 42:8-15"}],
            nt: [%{style: "req", read: "2 Cor 5:14-20a"}],
            gs: [%{style: "req", read: "Jn 20:11-18"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Judith 9:1, 11-14"}],
            ps: [%{style: "req", read: "Psalm 42:1-7"}, %{style: "opt", read: "Psalm 42:8-15"}],
            nt: [%{style: "req", read: "2 Cor 5:14-20a"}],
            gs: [%{style: "req", read: "Jn 20:11-18"}]
          }
        },
        "stJames" => %{
          "title" => "St. James (July 25)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Jer 45:1-5"}],
            ps: [%{style: "req", read: "Psalm 7:1-11"}, %{style: "opt", read: "Psalm 7:12-18"}],
            nt: [%{style: "req", read: "Acts 11:27-end, 12:1-3"}],
            gs: [%{style: "req", read: "Mt 20:20-28"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Jer 45:1-5"}],
            ps: [%{style: "req", read: "Psalm 7:1-11"}, %{style: "opt", read: "Psalm 7:12-18"}],
            nt: [%{style: "req", read: "Acts 11:27-end, 12:1-3"}],
            gs: [%{style: "req", read: "Mt 20:20-28"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Jer 45:1-5"}],
            ps: [%{style: "req", read: "Psalm 7:1-11"}, %{style: "opt", read: "Psalm 7:12-18"}],
            nt: [%{style: "req", read: "Acts 11:27-end, 12:1-3"}],
            gs: [%{style: "req", read: "Mt 20:20-28"}]
          }
        },
        "transfiguration" => %{
          "title" => "The Transfiguration (August 6)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Ex 34:29-35"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "2 Pet 1:13-21"}],
            gs: [%{style: "req", read: "Lk 9:28-36"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ex 34:29-35"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "2 Pet 1:13-21"}],
            gs: [%{style: "req", read: "Lk 9:28-36"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ex 34:29-35"}],
            ps: [%{style: "req", read: "Psalm 99"}],
            nt: [%{style: "req", read: "2 Pet 1:13-21"}],
            gs: [%{style: "req", read: "Lk 9:28-36"}]
          }
        },
        "bvm" => %{
          "title" => "St. Mary the Virgin (August 15)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 61:10-11"}],
            ps: [%{style: "req", read: "Psalm 34"}],
            nt: [%{style: "req", read: "Gal 4:4-7"}],
            gs: [%{style: "req", read: "Lk 1:46-55"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 61:10-11"}],
            ps: [%{style: "req", read: "Psalm 34"}],
            nt: [%{style: "req", read: "Gal 4:4-7"}],
            gs: [%{style: "req", read: "Lk 1:46-55"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 61:10-11"}],
            ps: [%{style: "req", read: "Psalm 34"}],
            nt: [%{style: "req", read: "Gal 4:4-7"}],
            gs: [%{style: "req", read: "Lk 1:46-55"}]
          }
        },
        "stBartholomew" => %{
          "title" => "St. Bartholomew (August 24)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 18:15-18"}],
            ps: [%{style: "req", read: "Psalm 91"}],
            nt: [%{style: "req", read: "1 Cor 4:9-16"}],
            gs: [%{style: "req", read: "Lk 22:24-30"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 18:15-18"}],
            ps: [%{style: "req", read: "Psalm 91"}],
            nt: [%{style: "req", read: "1 Cor 4:9-16"}],
            gs: [%{style: "req", read: "Lk 22:24-30"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 18:15-18"}],
            ps: [%{style: "req", read: "Psalm 91"}],
            nt: [%{style: "req", read: "1 Cor 4:9-16"}],
            gs: [%{style: "req", read: "Lk 22:24-30"}]
          }
        },
        "holyCross" => %{
          "title" => "Holy Cross Day (September 14)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Isaiah 45:21-25"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "Phil 2:5-11"}],
            gs: [%{style: "req", read: "Jn 12:31-36a"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Isaiah 45:21-25"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "Phil 2:5-11"}],
            gs: [%{style: "req", read: "Jn 12:31-36a"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Isaiah 45:21-25"}],
            ps: [%{style: "req", read: "Psalm 98"}],
            nt: [%{style: "req", read: "Phil 2:5-11"}],
            gs: [%{style: "req", read: "Jn 12:31-36a"}]
          }
        },
        "stMatthew" => %{
          "title" => "St. Matthew (September 21)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Prov 3:1-12"}],
            ps: [%{style: "req", read: "Psalm 119:33-40"}],
            nt: [%{style: "req", read: "2 Tim 3:1-17"}],
            gs: [%{style: "req", read: "Mt 9:9-13"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Prov 3:1-12"}],
            ps: [%{style: "req", read: "Psalm 119:33-40"}],
            nt: [%{style: "req", read: "2 Tim 3:1-17"}],
            gs: [%{style: "req", read: "Mt 9:9-13"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Prov 3:1-12"}],
            ps: [%{style: "req", read: "Psalm 119:33-40"}],
            nt: [%{style: "req", read: "2 Tim 3:1-17"}],
            gs: [%{style: "req", read: "Mt 9:9-13"}]
          }
        },
        "michaelAllAngels" => %{
          "title" => "St. Michael All Angels (September 29)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Gen 28:10-17"}],
            ps: [%{style: "req", read: "Psalm 103"}],
            nt: [%{style: "req", read: "Rev 12:7-12"}],
            gs: [%{style: "req", read: "Jn 1:47-51"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Gen 28:10-17"}],
            ps: [%{style: "req", read: "Psalm 103"}],
            nt: [%{style: "req", read: "Rev 12:7-12"}],
            gs: [%{style: "req", read: "Jn 1:47-51"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Gen 28:10-17"}],
            ps: [%{style: "req", read: "Psalm 103"}],
            nt: [%{style: "req", read: "Rev 12:7-12"}],
            gs: [%{style: "req", read: "Jn 1:47-51"}]
          }
        },
        "stLuke" => %{
          "title" => "St. Luke (October 18)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 38:1-14"}],
            ps: [%{style: "req", read: "Psalm 147:1-12"}],
            nt: [%{style: "req", read: "2 Tim 4:1-13"}],
            gs: [%{style: "req", read: "Lk 4:14-21"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 38:1-14"}],
            ps: [%{style: "req", read: "Psalm 147:1-12"}],
            nt: [%{style: "req", read: "2 Tim 4:1-13"}],
            gs: [%{style: "req", read: "Lk 4:14-21"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Ecclesiasticus 38:1-14"}],
            ps: [%{style: "req", read: "Psalm 147:1-12"}],
            nt: [%{style: "req", read: "2 Tim 4:1-13"}],
            gs: [%{style: "req", read: "Lk 4:14-21"}]
          }
        },
        "stJamesOfJerusalem" => %{
          "title" => "St. James of Jerusalem (October 23)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Acts 15:12-22a"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [%{style: "req", read: "1 Cor 15:1-11"}],
            gs: [%{style: "req", read: "Mt 13:54-58"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Acts 15:12-22a"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [%{style: "req", read: "1 Cor 15:1-11"}],
            gs: [%{style: "req", read: "Mt 13:54-58"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Acts 15:12-22a"}],
            ps: [%{style: "req", read: "Psalm 1"}],
            nt: [%{style: "req", read: "1 Cor 15:1-11"}],
            gs: [%{style: "req", read: "Mt 13:54-58"}]
          }
        },
        "stsSimonAndJude" => %{
          "title" => "St. Simon St. Jude (October 28)",
          "colors" => ["red"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 32:1-4"}],
            ps: [%{style: "req", read: "Psalm 119:89-96"}],
            nt: [%{style: "req", read: "Eph 2:13-22"}],
            gs: [%{style: "req", read: "Jn 15:17-27"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 32:1-4"}],
            ps: [%{style: "req", read: "Psalm 119:89-96"}],
            nt: [%{style: "req", read: "Eph 2:13-22"}],
            gs: [%{style: "req", read: "Jn 15:17-27"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 32:1-4"}],
            ps: [%{style: "req", read: "Psalm 119:89-96"}],
            nt: [%{style: "req", read: "Eph 2:13-22"}],
            gs: [%{style: "req", read: "Jn 15:17-27"}]
          }
        },
        "allSaints" => %{
          "title" => "All Saints (November 1)",
          "colors" => ["red"],
          "a" => %{
            ot: [
              %{style: "req", read: "Ecclesiasticus 44:1-14"},
              %{style: "alt", read: "Rev 7:9-17"}
            ],
            ps: [%{style: "req", read: "Psalm 149"}],
            nt: [
              %{style: "req", read: "Rev 7:9-17"},
              %{style: "opt", read: "Eph 1:11-14"},
              %{style: "alt", read: "Eph 1:15-23"}
            ],
            gs: [
              %{style: "req", read: "Mt 5:1-12"},
              %{style: "alt", read: "Lk 6:20-26"},
              %{style: "opt", read: "Lk 6:27-36"}
            ]
          },
          "b" => %{
            ot: [
              %{style: "req", read: "Ecclesiasticus 44:1-14"},
              %{style: "alt", read: "Rev 7:9-17"}
            ],
            ps: [%{style: "req", read: "Psalm 149"}],
            nt: [
              %{style: "req", read: "Rev 7:9-17"},
              %{style: "opt", read: "Eph 1:11-14"},
              %{style: "alt", read: "Eph 1:15-23"}
            ],
            gs: [
              %{style: "req", read: "Mt 5:1-12"},
              %{style: "alt", read: "Lk 6:20-26"},
              %{style: "opt", read: "Lk 6:27-36"}
            ]
          },
          "c" => %{
            ot: [
              %{style: "req", read: "Ecclesiasticus 44:1-14"},
              %{style: "alt", read: "Rev 7:9-17"}
            ],
            ps: [%{style: "req", read: "Psalm 149"}],
            nt: [
              %{style: "req", read: "Rev 7:9-17"},
              %{style: "opt", read: "Eph 1:11-14"},
              %{style: "alt", read: "Eph 1:15-23"}
            ],
            gs: [
              %{style: "req", read: "Mt 5:1-12"},
              %{style: "alt", read: "Lk 6:20-26"},
              %{style: "opt", read: "Lk 6:27-36"}
            ]
          }
        },
        "thanksgiving" => %{
          "title" => "Thanksgiving Day (Canada and the United States)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Deut 8"}],
            ps: [%{style: "req", read: "Psalm 65:1-8"}, %{style: "opt", read: "Psalm 65:9-14"}],
            nt: [%{style: "req", read: "James 1:17-27"}],
            gs: [%{style: "req", read: "Mt 6:25-33"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Deut 8"}],
            ps: [%{style: "req", read: "Psalm 65:1-8"}, %{style: "opt", read: "Psalm 65:9-14"}],
            nt: [%{style: "req", read: "James 1:17-27"}],
            gs: [%{style: "req", read: "Mt 6:25-33"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Deut 8"}],
            ps: [%{style: "req", read: "Psalm 65:1-8"}, %{style: "opt", read: "Psalm 65:9-14"}],
            nt: [%{style: "req", read: "James 1:17-27"}],
            gs: [%{style: "req", read: "Mt 6:25-33"}]
          }
        },
        "remembrance" => %{
          "title" =>
            "Remembrance Day (Canada: November 11) and Memorial Day(United States: Monday nearest May 28)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Wisdom 3:1-9"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 11:21-27"}, %{style: "alt", read: "Jn 15:12-17"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Wisdom 3:1-9"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 11:21-27"}, %{style: "alt", read: "Jn 15:12-17"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Wisdom 3:1-9"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 11:21-27"}, %{style: "alt", read: "Jn 15:12-17"}]
          }
        },
        "memorial" => %{
          "title" => "Memorial Day(United States: Monday nearest May 28)",
          "colors" => ["white"],
          "a" => %{
            ot: [%{style: "req", read: "Wisdom 3:1-9"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 11:21-27"}, %{style: "alt", read: "Jn 15:12-17"}]
          },
          "b" => %{
            ot: [%{style: "req", read: "Wisdom 3:1-9"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 11:21-27"}, %{style: "alt", read: "Jn 15:12-17"}]
          },
          "c" => %{
            ot: [%{style: "req", read: "Wisdom 3:1-9"}],
            ps: [%{style: "req", read: "Psalm 121"}],
            nt: [%{style: "req", read: "Rev 7:9-17"}],
            gs: [%{style: "req", read: "Jn 11:21-27"}, %{style: "alt", read: "Jn 15:12-17"}]
          }
        }
      }
    }
  end

  def readingList() do
    [
      {"advent", "1", "a"},
      {"advent", "2", "a"},
      {"advent", "3", "a"},
      {"advent", "4", "a"},
      {"christmasDay", "1", "a"},
      {"christmasDay", "2", "a"},
      {"christmasDay", "3", "a"},
      {"christmas", "1", "a"},
      {"holyName", "1", "a"},
      {"christmas", "2", "a"},
      {"theEpiphany", "1", "a"},
      {"epiphany", "1", "a"},
      {"epiphany", "2", "a"},
      {"epiphany", "3", "a"},
      {"epiphany", "4", "a"},
      {"epiphany", "5", "a"},
      {"epiphany", "6", "a"},
      {"presentation", "1", "a"},
      {"epiphany", "7", "a"},
      {"epiphany", "8", "a"},
      {"epiphany", "9", "a"},
      {"ashWednesday", "1", "a"},
      {"lent", "1", "a"},
      {"lent", "2", "a"},
      {"lent", "3", "a"},
      {"lent", "4", "a"},
      {"lent", "5", "a"},
      {"palmSundayPalms", "1", "a"},
      {"palmSunday", "1", "a"},
      {"holyWeek", "1", "a"},
      {"holyWeek", "2", "a"},
      {"holyWeek", "3", "a"},
      {"holyWeek", "4", "a"},
      {"holyWeek", "5", "a"},
      {"holyWeek", "6", "a"},
      {"easterDayVigil", "1", "a"},
      {"easterDay", "1", "a"},
      {"easterDay", "2", "a"},
      {"easterDay", "3", "a"},
      {"easterWeek", "1", "a"},
      {"easterWeek", "2", "a"},
      {"easterWeek", "3", "a"},
      {"easterWeek", "4", "a"},
      {"easterWeek", "5", "a"},
      {"easterWeek", "6", "a"},
      {"easter", "2", "a"},
      {"easter", "3", "a"},
      {"easter", "4", "a"},
      {"easter", "5", "a"},
      {"easter", "6", "a"},
      {"easter", "7", "a"},
      {"ascension", "1", "a"},
      {"pentecost", "1", "a"},
      {"pentecostWeekday", "1", "a"},
      {"pentecostWeekday", "2", "a"},
      {"trinity", "1", "a"},
      {"proper", "1", "a"},
      {"proper", "2", "a"},
      {"proper", "3", "a"},
      {"proper", "4", "a"},
      {"proper", "5", "a"},
      {"proper", "6", "a"},
      {"proper", "7", "a"},
      {"proper", "8", "a"},
      {"proper", "9", "a"},
      {"proper", "10", "a"},
      {"proper", "11", "a"},
      {"proper", "12", "a"},
      {"proper", "13", "a"},
      {"proper", "14", "a"},
      {"proper", "15", "a"},
      {"proper", "16", "a"},
      {"proper", "17", "a"},
      {"proper", "18", "a"},
      {"proper", "19", "a"},
      {"proper", "20", "a"},
      {"proper", "21", "a"},
      {"proper", "22", "a"},
      {"proper", "23", "a"},
      {"proper", "24", "a"},
      {"proper", "25", "a"},
      {"proper", "26", "a"},
      {"proper", "27", "a"},
      {"proper", "28", "a"},
      {"proper", "29", "a"},
      {"allSaints", "1", "a"},
      {"advent", "1", "b"},
      {"advent", "2", "b"},
      {"advent", "3", "b"},
      {"advent", "4", "b"},
      {"christmasDay", "1", "b"},
      {"christmasDay", "2", "b"},
      {"christmasDay", "3", "b"},
      {"christmas", "1", "b"},
      {"holyName", "1", "b"},
      {"christmas", "2", "b"},
      {"theEpiphany", "1", "b"},
      {"epiphany", "1", "b"},
      {"epiphany", "2", "b"},
      {"epiphany", "3", "b"},
      {"epiphany", "4", "b"},
      {"epiphany", "5", "b"},
      {"epiphany", "6", "b"},
      {"presentation", "1", "b"},
      {"epiphany", "7", "b"},
      {"epiphany", "8", "b"},
      {"epiphany", "9", "b"},
      {"ashWednesday", "1", "b"},
      {"lent", "1", "b"},
      {"lent", "2", "b"},
      {"lent", "3", "b"},
      {"lent", "4", "b"},
      {"lent", "5", "b"},
      {"palmSundayPalms", "1", "b"},
      {"palmSunday", "1", "b"},
      {"holyWeek", "1", "b"},
      {"holyWeek", "2", "b"},
      {"holyWeek", "3", "b"},
      {"holyWeek", "4", "b"},
      {"holyWeek", "5", "b"},
      {"holyWeek", "6", "b"},
      {"easterDayVigil", "1", "b"},
      {"easterDay", "1", "b"},
      {"easterDay", "2", "b"},
      {"easterDay", "3", "b"},
      {"easterWeek", "1", "b"},
      {"easterWeek", "2", "b"},
      {"easterWeek", "3", "b"},
      {"easterWeek", "4", "b"},
      {"easterWeek", "5", "b"},
      {"easterWeek", "6", "b"},
      {"easter", "2", "b"},
      {"easter", "3", "b"},
      {"easter", "4", "b"},
      {"easter", "5", "b"},
      {"easter", "6", "b"},
      {"easter", "7", "b"},
      {"ascension", "1", "b"},
      {"pentecost", "1", "b"},
      {"pentecostWeekday", "1", "b"},
      {"pentecostWeekday", "2", "b"},
      {"trinity", "1", "b"},
      {"proper", "1", "b"},
      {"proper", "2", "b"},
      {"proper", "3", "b"},
      {"proper", "4", "b"},
      {"proper", "5", "b"},
      {"proper", "6", "b"},
      {"proper", "7", "b"},
      {"proper", "8", "b"},
      {"proper", "9", "b"},
      {"proper", "10", "b"},
      {"proper", "11", "b"},
      {"proper", "12", "b"},
      {"proper", "13", "b"},
      {"proper", "14", "b"},
      {"proper", "15", "b"},
      {"proper", "16", "b"},
      {"proper", "17", "b"},
      {"proper", "18", "b"},
      {"proper", "19", "b"},
      {"proper", "20", "b"},
      {"proper", "21", "b"},
      {"proper", "22", "b"},
      {"proper", "23", "b"},
      {"proper", "24", "b"},
      {"proper", "25", "b"},
      {"proper", "26", "b"},
      {"proper", "27", "b"},
      {"proper", "28", "b"},
      {"proper", "29", "b"},
      {"allSaints", "1", "b"},
      {"advent", "1", "c"},
      {"advent", "2", "c"},
      {"advent", "3", "c"},
      {"advent", "4", "c"},
      {"christmasDay", "1", "c"},
      {"christmasDay", "2", "c"},
      {"christmasDay", "3", "c"},
      {"christmas", "1", "c"},
      {"holyName", "1", "c"},
      {"christmas", "2", "c"},
      {"theEpiphany", "1", "c"},
      {"epiphany", "1", "c"},
      {"epiphany", "2", "c"},
      {"epiphany", "3", "c"},
      {"epiphany", "4", "c"},
      {"epiphany", "5", "c"},
      {"epiphany", "6", "c"},
      {"presentation", "1", "c"},
      {"epiphany", "7", "c"},
      {"epiphany", "8", "c"},
      {"epiphany", "9", "c"},
      {"ashWednesday", "1", "c"},
      {"lent", "1", "c"},
      {"lent", "2", "c"},
      {"lent", "3", "c"},
      {"lent", "4", "c"},
      {"lent", "5", "c"},
      {"palmSundayPalms", "1", "c"},
      {"palmSunday", "1", "c"},
      {"holyWeek", "1", "c"},
      {"holyWeek", "2", "c"},
      {"holyWeek", "3", "c"},
      {"holyWeek", "4", "c"},
      {"holyWeek", "5", "c"},
      {"holyWeek", "6", "c"},
      {"easterDayVigil", "1", "c"},
      {"easterDay", "1", "c"},
      {"easterDay", "2", "c"},
      {"easterDay", "3", "c"},
      {"easterWeek", "1", "c"},
      {"easterWeek", "2", "c"},
      {"easterWeek", "3", "c"},
      {"easterWeek", "4", "c"},
      {"easterWeek", "5", "c"},
      {"easterWeek", "6", "c"},
      {"easter", "2", "c"},
      {"easter", "3", "c"},
      {"easter", "4", "c"},
      {"easter", "5", "c"},
      {"easter", "6", "c"},
      {"easter", "7", "c"},
      {"ascension", "1", "c"},
      {"pentecost", "1", "c"},
      {"pentecostWeekday", "1", "c"},
      {"pentecostWeekday", "2", "c"},
      {"trinity", "1", "c"},
      {"proper", "1", "c"},
      {"proper", "2", "c"},
      {"proper", "3", "c"},
      {"proper", "4", "c"},
      {"proper", "5", "c"},
      {"proper", "6", "c"},
      {"proper", "7", "c"},
      {"proper", "8", "c"},
      {"proper", "9", "c"},
      {"proper", "10", "c"},
      {"proper", "11", "c"},
      {"proper", "12", "c"},
      {"proper", "13", "c"},
      {"proper", "14", "c"},
      {"proper", "15", "c"},
      {"proper", "16", "c"},
      {"proper", "17", "c"},
      {"proper", "18", "c"},
      {"proper", "19", "c"},
      {"proper", "20", "c"},
      {"proper", "21", "c"},
      {"proper", "22", "c"},
      {"proper", "23", "c"},
      {"proper", "24", "c"},
      {"proper", "25", "c"},
      {"proper", "26", "c"},
      {"proper", "27", "c"},
      {"proper", "28", "c"},
      {"proper", "29", "c"},
      {"allSaints", "1", "c"},
      {"redLetter", "transfiguration", "c"},
      {"redLetter", "stJamesOfJerusalem", "c"},
      {"redLetter", "stJohn", "c"},
      {"redLetter", "confessionOfStPeter", "c"},
      {"redLetter", "annunciation", "c"},
      {"redLetter", "holyInnocents", "c"},
      {"redLetter", "conversionOfStPaul", "c"},
      {"redLetter", "stsPhilipAndJames", "c"},
      {"redLetter", "bvm", "c"},
      {"redLetter", "stPeterAndPaul", "c"},
      {"redLetter", "visitation", "c"},
      {"redLetter", "michaelAllAngels", "c"},
      {"redLetter", "stBarnabas", "c"},
      {"redLetter", "memorial", "c"},
      {"redLetter", "thanksgiving", "c"},
      {"redLetter", "presentation", "c"},
      {"redLetter", "allSaints", "c"},
      {"redLetter", "stLuke", "c"},
      {"redLetter", "independence", "c"},
      {"redLetter", "stThomas", "c"},
      {"redLetter", "stJames", "c"},
      {"redLetter", "nativityOfJohnTheBaptist", "c"},
      {"redLetter", "stMaryMagdalene", "c"},
      {"redLetter", "stMatthew", "c"},
      {"redLetter", "remembrance", "c"},
      {"redLetter", "stBartholomew", "c"},
      {"redLetter", "stsSimonAndJude", "c"},
      {"redLetter", "holyCross", "c"},
      {"redLetter", "stStephen", "c"},
      {"redLetter", "dominion", "c"},
      {"redLetter", "stMatthias", "c"},
      {"redLetter", "stJoseph", "c"},
      {"redLetter", "stMark", "c"},
      {"redLetter", "stAndrew", "c"}
    ]
  end
end
