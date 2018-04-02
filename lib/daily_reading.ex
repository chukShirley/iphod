require IEx
defmodule DailyReading do
  import IphodWeb.Gettext, only: [dgettext: 2]
  # import Psalms, only: [morning: 1, evening: 1]
  import SundayReading, only: [collect_today: 1, colors: 1]
  import Lityear, only: [to_season: 1]
  use Timex
  def start_link, do: Agent.start_link fn -> build() end, name: __MODULE__
  def identity(), do: Agent.get(__MODULE__, &(&1))
  def mp_body(date, versions_map \\ %{mpp: "BCP", mp1: "ESV", mp2: "ESV"}) do
    mp = mp_today(date)
    [:mp1, :mp2, :mpp]
      |> Enum.reduce(mp, fn(r, acc)->
        acc |> Map.put(r, BibleText.lesson_with_body(mp[r], versions_map[r]) )
      end)
    |> Map.put(:show, true)
    |> Map.put(:collect, collect_today(date))
  end
  def ep_body(date, versions_map \\ %{epp: "BCP", ep1: "ESV", ep2: "ESV"}) do
    ep = ep_today(date)
    [:ep1, :ep2, :epp]
      |> Enum.reduce(ep, fn(r, acc)->
        acc |> Map.put(r, BibleText.lesson_with_body(ep[r], versions_map[r]) )
      end)
    |> Map.put(:show, true)
    |> Map.put(:collect, collect_today(date))
  end
  def opening_sentence(mpep, date) do
    {season, _wk, _lityr, _date} = Lityear.to_season(date, true) # set true for mpep
    _opening_sentence(mpep, season) |> pick_one(date)
  end
  def _opening_sentence(mpep, "ashWednesday"),  do: identity()["#{mpep}_opening"]["lent"]
  def _opening_sentence(mpep, "palmSunday"),    do: identity()["#{mpep}_opening"]["lent"]
  def _opening_sentence(mpep, "holyWeek"),      do: identity()["#{mpep}_opening"]["lent"]
  def _opening_sentence(mpep, "easterDay"),     do: identity()["#{mpep}_opening"]["easter"]
  def _opening_sentence(mpep, "ascension"),     do: identity()["#{mpep}_opening"]["easter"]
  def _opening_sentence(mpep, "theEpiphany"),   do: identity()["#{mpep}_opening"]["epiphany"]
  def _opening_sentence(mpep, season),          do: identity()["#{mpep}_opening"][season]
  def antiphon(date) do
    {season, _wk, _lityr, _date} = Lityear.to_season(date, true)
    _antiphon(season) |> pick_one(date)
  end
  def _antiphon("ashWednesday"),  do: identity()["antiphon"]["lent"]
  def _antiphon("holyWeek"),    do: identity()["antiphon"]["lent"]
  def _antiphon("goodFriday"),    do: identity()["antiphon"]["lent"]
  def _antiphon("ascension"),     do: identity()["antiphon"]["easter"]
  def _antiphon("theEpiphany"),   do: identity()["antiphon"]["epiphany"]
  def _antiphon(season),          do: identity()["antiphon"][season]
  def pick_one(list, date) do
    if list == nil, do: IEx.pry
    len = length list
    at = rem Timex.day(date), len
    Enum.at list, at
  end

  def readings(date) do
    day = date |> Timex.format!("%B%d", :strftime)
    dayName = date |> Timex.format!("%A", :strftime)
    {season, wk, _litYr, _date} = date |> to_season
    r = identity()[day]
    if !r, do: IEx.pry

    %{  colors: SundayReading.colors(date),
        date: date |> Timex.format!("%A %B %e, %Y", :strftime),
        day: dayName,
        ep1: [ %{body: "", id: vssToId(r.ep1), read: r.ep1, section: "ep1", show: false, show_fn: true, show_vn: true, style: "req", version: ""}],
        ep2: [ %{body: "", id: vssToId(r.ep2), read: r.ep2, section: "ep2", show: false, show_fn: true, show_vn: true, style: "req", version: ""}],
        epp: mapPsalmsToWithBody("ep", date),
        mp1: [ %{body: "", id: vssToId(r.mp1), read: r.mp1, section: "mp1", show: false, show_fn: true, show_vn: true, style: "req", version: ""}],
        mp2: [ %{body: "", id: vssToId(r.mp2), read: r.mp2, section: "mp2", show: false, show_fn: true, show_vn: true, style: "req", version: ""}],
        mpp: mapPsalmsToWithBody("mp", date),
        season: season,
        title: (if r.title |> String.length == 0, do: dayName, else: r.title),
        week: wk
      }

  end
  
  def day_of_week({"christmas", "1", _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    dec_n =  date |> Timex.format!("{D}")
    cond do
      dec_n == "24" -> {"christmas", "1", "christmasEve", date}
      dec_n == "25" -> {"christmas", "1", "christmasDay", date}
      dow == "Sunday" -> {"christmas", "1", "Sunday", date}
      dec_n == "26" -> {"christmas", "1", "stStephen", date}
      dec_n == "27" -> {"christmas", "1", "stJohn", date}
      dec_n == "28" -> {"christmas", "1", "holyInnocents", date}
      dec_n == "29" -> {"christmas", "1", "Dec29", date}
      dec_n == "30" -> {"christmas", "1", "Dec30", date}
      dec_n == "31" -> {"christmas", "1", "Dec31", date}
      dec_n == "1"  -> {"christmas", "1", "octaveChristmas", date}  # Jan 1
      dec_n == "2"  -> {"christmas", "2", "Jan02", date}            # these date can also fall in Christmas 1
      dec_n == "3"  -> {"christmas", "2", "Jan03", date}            # these date can also fall in Christmas 1
      dec_n == "4"  -> {"christmas", "2", "Jan04", date}            # these date can also fall in Christmas 1
      dec_n == "5"  -> {"christmas", "2", "Jan05", date}            # these date can also fall in Christmas 1
      dec_n == "6"  -> {"epiphany",  "0", dow, date}                # these date can also fall in Christmas 1
      true -> dow
    end
  end
  def day_of_week({"christmas", "2", _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    jan_n =  date |> Timex.format!("{D}")
    cond do
      dow == "Sunday" -> {"christmas", "2", "Sunday", date}
      jan_n == "2"  -> {"christmas", "2", "Jan02", date}
      jan_n == "3"  -> {"christmas", "2", "Jan03", date}
      jan_n == "4"  -> {"christmas", "2", "Jan04", date}
      jan_n == "5"  -> {"christmas", "2", "Jan05", date}
      jan_n == "6"  -> {"epiphany", "0", dow, date}
      jan_n == "7"  -> {"epiphany", "0", dow, date}
      jan_n == "8"  -> {"epiphany", "0", dow, date}
      jan_n == "9"  -> {"epiphany", "0", dow, date}
      jan_n == "10" -> {"epiphany", "0", dow, date}
      jan_n == "11" -> {"epiphany", "0", dow, date}
      true -> dow
    end
  end
  def day_of_week({"redLetter", wk, litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    {new_season, new_wk, _litYr, _date} = date |> Lityear.last_sunday
    {new_season, new_wk, dow, date}
  end
  def day_of_week({season, wk, _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    {season, wk, dow, date}
  end

  def lesson(date, section, ver) do
    readings(date)[section |> String.to_atom]
    |> BibleText.lesson_with_body(ver)
  end

  def mapPsalmsToWithBody(mpep, date) do
    day = date.day
    {section, pss} = if mpep == "mp", do: {"mpp", Psalms.morning(day)}, else: {"epp", Psalms.evening(day)}
    pss
      |> Enum.map( fn(ps) ->
        if ps |> is_tuple do
          {p, vsStart, vsEnd} = ps
            %{  body: "", 
                id: "Psalm_#{p}_#{vsStart}_#{vsEnd}", 
                read: "Psalm #{p}:#{vsStart}-#{vsEnd}", 
                section: section, 
                style: "req",
                show: false, show_fn: true, show_vn: true, version: ""
              }
          else
            %{  body: "", 
                id: "Psalm_#{ps}", 
                read: "Psalm #{ps}", 
                section: section, 
                style: "req",
                show: false, show_fn: true, show_vn: true, version: ""
              }
        end
      end)
  end

  defp vssToId(vss) do
    Regex.replace(~r/[\s\.\:\,]/, vss, "_")
  end

  defp to_lessons(map) do
    map
      |> Map.update(:mp1, [], fn(el)-> _to_lessons_for("mp1", el) end)
      |> Map.update(:mp2, [], fn(el)-> _to_lessons_for("mp2", el) end)
      |> Map.update(:mpp, [], fn(el)-> _to_lessons_for("mpp", el) end)
      |> Map.update(:ep1, [], fn(el)-> _to_lessons_for("ep1", el) end)
      |> Map.update(:ep2, [], fn(el)-> _to_lessons_for("ep2", el) end)
      |> Map.update(:epp, [], fn(el)-> _to_lessons_for("epp", el) end)
  end
  defp _to_lessons_for(_section, []), do: []
  defp _to_lessons_for(section, list) do
    list |> Enum.map(fn(el)-> _add_keys_for(section, el) end)
  end
  defp _add_keys_for(section, map) do
    if map |> Map.has_key?(:read) do
      map |> Map.put_new(:id, vssToId(map.read) )
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
  def mp_today(date) do
    r = readings(date)
    day = if r.title |> String.length == 0, do: date |> Timex.format("%A", :strftime), else: r.title
    {season, week, _litYr, _date} = date |> to_season
    %{
      colors: colors(date),
      date:   r.date,
      day:    day,
      season: season,
      title:  r.title,
      week:   week,
      mp1:    r.mp1,
      mp2:    r.mp2,
      mpp:    r.mpp,
      show:   false,
      sectionUpdate: %{section: "", version: "", ref: ""}
    }
    # get the ESV text, put it the body for mp1, mp2, mpp
  end
  def ep_today(date) do
    r = readings(date)
    day = if r.title |> String.length == 0, do: date |> Timex.format("%A", :strftime), else: r.title
    {season, week, _litYr, _date} = date |> to_season
    %{
      colors: colors(date),
      date:   date,
      day:    day,
      season: season,
      title:  r.title,
      week:   week,
      ep1:    r.ep1,
      ep2:    r.ep2,
      epp:    r.epp,
      show:   false,
      sectionUpdate: %{section: "", version: "", ref: ""}
    }
    # get the ESV text, put it the body for ep1, ep2, epp
  end
  def reading_map("mp", date) do
    r = readings(date)
    %{  mp1: r.mp1 |> Enum.map(&(&1.read)),
        mp2: r.mp2 |> Enum.map(&(&1.read)),
        mpp: r.mpp |> Enum.map(&(&1.read))
    }
  end
  def reading_map("ep", date) do
    r = readings(date)
    %{  ep1: r.ep1 |> Enum.map(&(&1.read)),
        ep2: r.ep2 |> Enum.map(&(&1.read)),
        epp: r.epp |> Enum.map(&(&1.read))
    }
  end
  def title_for(date) do
    {rldDate, rldName} = Lityear.next_holy_day(date)
    if date == rldDate, do: Lityear.hd_title(rldName), else: readings(date).title
  end

  def build do
    %{"antiphon" =>
      %{  "advent" =>
            [dgettext("antiphon", "Our King and Savior now draws near: O come, let us adore him.")],
          "christmas" =>
            [dgettext("antiphon", "Alleluia, to us a child is born: O come, let us adore him. Alleluia.")],
          "epiphany" =>
            [dgettext("antiphon", "The Lord has shown forth his glory: O come, let us adore him.")],
          "lent" =>
            [dgettext("antiphon", "The Lord is full of compassion and mercy: O come, let us adore him.")],
          "palmSunday" =>
            [dgettext("antiphon", "The Lord is full of compassion and mercy: O come, let us adore him.")],
          "easterDay" =>
            [dgettext("antiphon", "Alleluia. The Lord is risen indeed: O come, let us adore him. Alleluia.")],
          "easter" =>
            [dgettext("antiphon", "Alleluia. The Lord is risen indeed: O come, let us adore him. Alleluia.")],
          "proper" =>
            [dgettext("antiphon", "The earth is the Lord's for he made it: O Come let us adore him."),
             dgettext("antiphon", "Worship the Lord in the beauty of holiness: O Come let us adore him."),
             dgettext("antiphon", "The mercy of the Lord is everlasting: O Come let us adore him."),
             dgettext("antiphon", "Worship the Lord in the beauty of holiness: O Come let us adore him.")
            ],
          "ascension" =>
            [dgettext("antiphon", "Alleluia. Christ the Lord has ascended into heaven: O come, let us adore him. Alleluia.")],
          "pentecost" =>
            [dgettext("antiphon", "Alleluia. The Spirit of the Lord renews the face of the earth: O come, let us adore him. Alleluia.")],
          "trinity" =>
            [dgettext("antiphon", "Father, Son and Holy Spirit, one God: O come, let us adore him.")],
          "incarnation" =>
            [dgettext("antiphon", "The Word was made flesh and dwelt among us: O come, let us adore him.")],
          "saints" =>
            [dgettext("antiphon", "The Lord is glorious in his saints: O come, let us adore him.")]
      },
      "mp_opening" =>
      %{ "advent" => [{
                  dgettext( "mp_opening", "In the wilderness prepare the way of the Lord; make straight in the desert a highway for our God."),
                  dgettext( "mp_opening", "Isaiah 40:3")
                  }],
        "christmas" => [{
                    dgettext( "mp_opening", "Fear not, for behold, I bring you good news of a great joy that will be for all people. For unto you is born this day in the city of David a Savior, who is Christ the Lord."),
                    dgettext( "mp_opening", "Luke 2:10-11")
                    }],
        "epiphany" => [{
                    dgettext( "mp_opening", "For from the rising of the sun to its setting my name will be great among the nations, and in every place incense will be offered to my name, and a pure offering. For my name will be great among the nations, says the Lord of hosts."),
                    dgettext( "mp_opening", "Malachi 1:11")
                    }],
        "lent" => [{
                    dgettext( "mp_opening", "Repent, for the kingdom of heaven is at hand."),
                    dgettext( "mp_opening", "Matthew 3:2")
                    }],
        "goodFriday" => [{
                    dgettext( "mp_opening", "Is it nothing to you, all you who pass by? Look and see if there is any sorrow like my sorrow, which was brought upon me, which the Lord inflicted on the day of his fierce anger."),
                    dgettext( "mp_opening", "Lamentations 1:12"),
                    }],
        "easter" => [{
                   dgettext( "mp_opening",  "Christ is risen! The Lord is risen indeed!"),
                    dgettext( "mp_opening", "Mark 16:6 and Luke 24:34")
                    }],
        "ascension" => [{
                    dgettext( "mp_opening", "Since then we have a great high priest who has passed through the heavens, Jesus, the Son of God, let us hold fast our confession. Let us then with confidence draw near to the throne of grace, that we may receive mercy and find grace to help in time of need."),
                    dgettext( "mp_opening", "Hebrews 4:14, 16")
                    }],
        "pentecost" => [{
                    dgettext( "mp_opening", "You will receive power when the Holy Spirit has come upon you, and you will be my witnesses in Jerusalem and in all Judea and Samaria, and to the end of the earth."),
                    dgettext( "mp_opening", "Acts 1:8")
                    }],
        "trinity" => [{
                    dgettext( "mp_opening", "Holy, holy, holy, is the Lord God Almighty, who was and is and is to come!"),
                    dgettext( "mp_opening", "Revelation 4:8")
                    }],
        "thanksgiving" => [{
                    dgettext( "mp_opening", "Honor the Lord with your wealth and with the firstfruits of all your produce; then your barns will be filled with plenty, and your vats will be bursting with wine."),
                    dgettext( "mp_opening", "Proverbs 3:9-10")
                    }],
        "proper" =>
          [ { dgettext("mp_opening", "The Lord is in his holy temple; let all the earth keep silence before him."),
              dgettext("mp_opening", "Habakkuk 2:20")
            },
            { dgettext("mp_opening", "I was glad when they said to me, “Let us go to the house of the Lord!”"),
              dgettext("mp_opening", "Psalm 122:1")
            },
            { dgettext("mp_opening", "Let the words of my mouth and the meditation of my heart be acceptable in your sight, O Lord, my rock and my redeemer."),
              dgettext("mp_opening", "Psalm 19:14")
            },
            { dgettext("mp_opening", "Send out your light and your truth; let them lead me; let them bring me to your holy hill and to your dwelling!"),
              dgettext("mp_opening", "Psalm 43:3")
            },
            { dgettext("mp_opening", "For thus says the One who is high and lifted up, who inhabits eternity, whose name is Holy: “I dwell in the high and holy place, and also with him who is of a contrite and lowly spirit, to revive the spirit of the lowly, and to revive the heart of the contrite.”"),
              dgettext("mp_opening", "Isaiah 57:15")
            },
            { dgettext("mp_opening", "The hour is coming, and is now here, when the true worshipers will worship the Father in spirit and truth, for the Father is seeking such people to worship him."),
              dgettext("mp_opening", "John 4:23")
            },
            { dgettext("mp_opening", "Grace to you and peace from God our Father and the Lord Jesus Christ."),
              dgettext("mp_opening", "Philippians 1:2")
            }
          ]
      },
      "ep_opening" =>
        %{  "advent" => [{
              dgettext( "ep_opening", """
                Therefore stay awake – for you do not know when the master of the
              house will come, in the evening, or at midnight, or when the cock
              crows, or in the morning – lest he come suddenly and find you asleep.
              """),
              dgettext( "ep_opening", "Mark 13:35-36")
            }],
            "christmas" => [{
              dgettext( "ep_opening", """
                Behold, the dwelling place of God is with man. He will dwell with
              them, and they will be his people, and God himself will be with them
              as their God.
              """),
              dgettext( "ep_opening", "Revelation 21:3")
            }],
            "epiphany" => [{
              dgettext( "ep_opening", "Nations shall come to your light, and kings to the brightness of your rising."),
              dgettext( "ep_opening", "Isaiah 60:3")
            }],
            "lent" => [{
              dgettext( "ep_opening", """
                If we say we have no sin, we deceive ourselves, and the truth is not in
                 us. If we confess our sins, he is faithful and just to forgive us our sins
                 and to cleanse us from all unrighteousness.
                 """),
              dgettext( "ep_opening", "1 John 1:8-9")
              },
              {( dgettext "ep_opening", "For I know my transgressions, and my sin is ever before me."),
                dgettext( "ep_opening", "Psalm 51:3")
              },
              {( dgettext "ep_opening", "To the Lord our God belong mercy and forgiveness, for we have rebelled against him."),
                dgettext( "ep_opening", "Daniel 9:9")
              }],
            "goodFriday" => [{
                dgettext( "ep_opening", """
                  All we like sheep have gone astray; we have turned every one to his
                own way; and the Lord has laid on him the iniquity of us all.
                """),
                dgettext( "ep_opening", "Isaiah 53:6")
              }],
            "easter" => [{
                dgettext( "ep_opening", "Thanks be to God, who gives us the victory through our Lord Jesus Christ."),
                dgettext( "ep_opening", "1 Corinthians 15:57")
                },
                {
                  dgettext( "ep_opening", """
                    If then you have been raised with Christ, seek the things that are
                  above, where Christ is, seated at the right hand of God.
                  """),
                  dgettext( "ep_opening", "Colossians 3:1")
                }],
            "ascension" => [{
                  dgettext( "ep_opening", """
                    For Christ has entered, not into holy places made with hands, which
                  are copies of the true things, but into heaven itself, now to appear in
                  the presence of God on our behalf.
                  """),
                  dgettext( "ep_opening", "Hebrews 9:24")
                }],
            "pentecost" => [{
                  dgettext( "ep_opening", """
                    The Spirit and the Bride say, “Come.” And let the one who hears say,
                  “Come.” And let the one who is thirsty come; let the one who desires
                  take the water of life without price.
                  """),
                  dgettext( "ep_opening", "Revelation 22:17")
                },
                {
                  dgettext( "ep_opening", """
                    There is a river whose streams make glad the city of God, the holy
                  habitation of the Most High.
                  """),
                  dgettext( "ep_opening", "Psalm 46:4")
                }],
            "trinity" => [{
                dgettext( "ep_opening", "Holy, holy, holy, is the Lord God of Hosts; the whole earth is full of his glory!"),
                dgettext( "ep_opening", "Isaiah 6:3")
                }],
            "thanksgiving" => [{
                dgettext( "ep_opening", """
                  The Lord by wisdom founded the earth; by understanding he
                  established the heavens; by his knowledge the deeps broke open, and
                  the clouds drop down the dew.
                  """),
                 dgettext( "ep_opening", "Proverbs 3:19-20")
                }],
            "proper" => [{
                dgettext( "ep_opening", "The Lord is in his holy temple; let all the earth keep silence before him."),
                dgettext( "ep_opening", "Habakkuk 2:20")
              },
              {
                dgettext( "ep_opening", "O Lord, I love the habitation of your house and the place where your glory dwells."),
                dgettext( "ep_opening", "Psalm 26:8")
              },
              {
                dgettext( "ep_opening", """
                  Let my prayer be counted as incense before you, and the lifting up of
                my hands as the evening sacrifice!
                """),
                dgettext( "ep_opening", "Psalm 141:2")
              },
              {
                dgettext( "ep_opening", "Worship the Lord in the splendor of holiness; tremble before him, all the earth!"),
                dgettext( "ep_opening", "Psalm 96:9")
              },
              {
                dgettext( "ep_opening", """
                  Let the words of my mouth and the meditation of my heart be
                acceptable in your sight, O Lord, my rock and my redeemer.
                """),
                dgettext( "ep_opening", "Psalm 19:14")
              }]
        },
      "January01" => %{
        title: "Holy Name",
        mp1: "Gen 1",
        mp2: "John 1:1-28",
        ep1: "Gen 2",
        ep2: "Gal 1"
        },
      "January02" => %{
        title: "",
        mp1: "Gen 3",
        mp2: "John 1:29-end",
        ep1: "Gen 4",
        ep2: "Gal 2"
        },
      "January03" => %{
        title: "",
        mp1: "Gen 5",
        mp2: "John 2",
        ep1: "Gen 6",
        ep2: "Gal 3"
        },
      "January04" => %{
        title: "",
        mp1: "Gen 7",
        mp2: "John 3:1-21",
        ep1: "Gen 8",
        ep2: "Gal 4"
        },
      "January05" => %{
        title: "",
        mp1: "Gen 9",
        mp2: "John 3:22-end",
        ep1: "Gen 10",
        ep2: "Gal 5"
        },
      "January06" => %{
        title: "Epiphany",
        mp1: "Gen 11",
        mp2: "John 4:1-26",
        ep1: "Gen 12",
        ep2: "Gal 6"
        },
      "January07" => %{
        title: "",
        mp1: "Gen 13",
        mp2: "John 4:27-end",
        ep1: "Gen 14",
        ep2: "1 Thess 1"
        },
      "January08" => %{
        title: "",
        mp1: "Gen 15",
        mp2: "John 5:1-23",
        ep1: "Gen 16",
        ep2: "1 Thess 2:1-16"
        },
      "January09" => %{
        title: "",
        mp1: "Gen 17",
        mp2: "John 5:24-end",
        ep1: "Gen 18",
        ep2: "1 Thess 2:17-end,3:1-end"
        },
      "January10" => %{
        title: "",
        mp1: "Gen 19",
        mp2: "John 6:1-21",
        ep1: "Gen 20",
        ep2: "1 Thess 4:1-12"
        },
      "January11" => %{
        title: "",
        mp1: "Gen 21",
        mp2: "John 6:22-40",
        ep1: "Gen 22",
        ep2: "1 Thess 4:13-5:11"
        },
      "January12" => %{
        title: "",
        mp1: "Gen 23",
        mp2: "John 6:41-end",
        ep1: "Gen 24",
        ep2: "1 Thess 5:12-end"
        },
      "January13" => %{
        title: "",
        mp1: "Gen 25",
        mp2: "John 7:1-24",
        ep1: "Gen 26",
        ep2: "2 Thess 1"
        },
      "January14" => %{
        title: "",
        mp1: "Gen 27",
        mp2: "John 7:25-end",
        ep1: "Gen 28",
        ep2: "2 Thess 2"
        },
      "January15" => %{
        title: "",
        mp1: "Gen 29",
        mp2: "John 8:1-30",
        ep1: "Gen 30",
        ep2: "2 Thess 3"
        },
      "January16" => %{
        title: "",
        mp1: "Gen 31",
        mp2: "John 8:31-end",
        ep1: "Gen 32",
        ep2: "1 Cor 1:1-25"
        },
      "January17" => %{
        title: "",
        mp1: "Gen 33",
        mp2: "John 9",
        ep1: "Gen 34",
        ep2: "1 Cor 1:26-end, 2:1-end"
        },
      "January18" => %{
        title: "Confession of St. Peter",
        mp1: "Gen 35",
        mp2: "John 10:1-21",
        ep1: "Gen 36",
        ep2: "1 Cor 3"
        },
      "January19" => %{
        title: "",
        mp1: "Gen 37",
        mp2: "John 10:22-end",
        ep1: "Gen 38",
        ep2: "1 Cor 4:1-17"
        },
      "January20" => %{
        title: "",
        mp1: "Gen 39",
        mp2: "John 11:1-44",
        ep1: "Gen 40",
        ep2: "1 Cor 4:18-end, 5" # "1 Cor 4:1-20" #, 5:1-999" # will this work?
        },
      "January21" => %{
        title: "",
        mp1: "Gen 41",
        mp2: "John 11:45-end",
        ep1: "Gen 42",
        ep2: "1 Cor 6"
        },
      "January22" => %{
        title: "",
        mp1: "Gen 43",
        mp2: "John 12:1-19",
        ep1: "Gen 44",
        ep2: "1 Cor 7"
        },
      "January23" => %{
        title: "",
        mp1: "Gen 45",
        mp2: "John 12:20-end",
        ep1: "Gen 46",
        ep2: "1 Cor 8"
        },
      "January24" => %{
        title: "",
        mp1: "Gen 47",
        mp2: "John 13",
        ep1: "Gen 48",
        ep2: "1 Cor 9"
        },
      "January25" => %{
        title: "Conversion of St. Paul",
        mp1: "Gen 49",
        mp2: "John 14:1-14",
        ep1: "Gen 50",
        ep2: "1 Cor 10"
        },
      "January26" => %{
        title: "",
        mp1: "Exod 1",
        mp2: "John 14:15-end",
        ep1: "Exod 2",
        ep2: "1 Cor 11"
        },
      "January27" => %{
        title: "",
        mp1: "Exod 3",
        mp2: "John 15:1-16",
        ep1: "Exod 4",
        ep2: "1 Cor 12"
        },
      "January28" => %{
        title: "",
        mp1: "Exod 5",
        mp2: "John 15:17-end",
        ep1: "Exod 6",
        ep2: "1 Cor 13"
        },
      "January29" => %{
        title: "",
        mp1: "Exod 7",
        mp2: "John 16:1-15",
        ep1: "Exod 8",
        ep2: "1 Cor 14:1-19"
        },
      "January30" => %{
        title: "",
        mp1: "Exod 9",
        mp2: "John 16:16-end",
        ep1: "Exod 10",
        ep2: "1 Cor 14:20-end"
        },
      "January31" => %{
        title: "",
        mp1: "Exod 11",
        mp2: "John 17",
        ep1: "Exod 12",
        ep2: "1 Cor 15:1-34"
        },
      "February01" => %{
        title: "",
        mp1: "Exod 13",
        mp2: "John 18:1-32",
        ep1: "Exod 14",
        ep2: "1 Cor 15:35-end"
        },
      "February02" => %{
        title: "Presentation",
        mp1: "Exod 15",
        mp2: "John 18:33-end",
        ep1: "Exod 16",
        ep2: "1 Cor 16"
        },
      "February03" => %{
        title: "",
        mp1: "Exod 17",
        mp2: "John 19:1-37",
        ep1: "Exod 18",
        ep2: "2 Cor 1:1-2:11"
        },
      "February04" => %{
        title: "",
        mp1: "Exod 19",
        mp2: "John 19:38-end",
        ep1: "Exod 20",
        ep2: "2 Cor 2:12-end, 3:1-end"
        },
      "February05" => %{
        title: "",
        mp1: "Exod 21",
        mp2: "John 20",
        ep1: "Exod 22",
        ep2: "2 Cor 4"
        },
      "February06" => %{
        title: "",
        mp1: "Exod 23",
        mp2: "John 21",
        ep1: "Exod 24",
        ep2: "2 Cor 5"
        },
      "February07" => %{
        title: "",
        mp1: "Exod 25",
        mp2: "Mark 1:1-13",
        ep1: "Exod 25",
        ep2: "2 Cor 6:1-19"
        },
      "February08" => %{
        title: "",
        mp1: "Exod 26",
        mp2: "Mark 1:14-31",
        ep1: "Exod 27",
        ep2: "2 Cor 6:20-end"
        },
      "February09" => %{
        title: "",
        mp1: "Exod 28",
        mp2: "Mark 1:32-end",
        ep1: "Exod 29",
        ep2: "2 Cor 7"
        },
      "February10" => %{
        title: "",
        mp1: "Exod 30",
        mp2: "Mark 2:1-22",
        ep1: "Exod 31",
        ep2: "2 Cor 8"
        },
      "February11" => %{
        title: "",
        mp1: "Exod 32",
        mp2: "Mark 2:23-3:12",
        ep1: "Exod 33",
        ep2: "2 Cor 9"
        },
      "February12" => %{
        title: "",
        mp1: "Exod 34",
        mp2: "Mark 3:13-end",
        ep1: "Exod 35",
        ep2: "2 Cor 10"
        },
      "February13" => %{
        title: "",
        mp1: "Exod 36",
        mp2: "Mark 4:1-34",
        ep1: "Exod 37",
        ep2: "2 Cor 11"
        },
      "February14" => %{
        title: "",
        mp1: "Exod 38",
        mp2: "Mark 4:35-5:20",
        ep1: "Exod 39",
        ep2: "2 Cor 12:1-13"
        },
      "February15" => %{
        title: "",
        mp1: "Exod 40",
        mp2: "Mark 5:21-end",
        ep1: "Lev 1",
        ep2: "2 Cor 12:14-end, 13:1-end"
        },
      "February16" => %{
        title: "",
        mp1: "Lev 8",
        mp2: "Mark 6:1-29",
        ep1: "Lev 16",
        ep2: "Rom 1"
        },
      "February17" => %{
        title: "",
        mp1: "Lev 18",
        mp2: "Mark 6:30-end",
        ep1: "Lev 19",
        ep2: "Rom 2"
        },
      "February18" => %{
        title: "",
        mp1: "Lev 20",
        mp2: "Mark 7:1-23",
        ep1: "Lev 23",
        ep2: "Rom 3"
        },
      "February19" => %{
        title: "",
        mp1: "Lev 26",
        mp2: "Mark 7:24-8:10",
        ep1: "Num 1",
        ep2: "Rom 4"
        },
      "February20" => %{
        title: "",
        mp1: "Num 6",
        mp2: "Mark 8:11-end",
        ep1: "Num 11",
        ep2: "Rom 5"
        },
      "February21" => %{
        title: "",
        mp1: "Num 12",
        mp2: "Mark 9:1-29",
        ep1: "Num 13",
        ep2: "Rom 6"
        },
      "February22" => %{
        title: "",
        mp1: "Num 14",
        mp2: "Mark 9:30-end",
        ep1: "Num 15",
        ep2: "Rom 7"
        },
      "February23" => %{
        title: "",
        mp1: "Num 16",
        mp2: "Mark 10:1-31",
        ep1: "Num 20",
        ep2: "Rom 8:1-17"
        },
      "February24" => %{
        title: "St. Matthias",
        mp1: "Num 22",
        mp2: "Mark 10:32-end",
        ep1: "Num 23",
        ep2: "Rom 8:18-end"
        },
      "February25" => %{
        title: "",
        mp1: "Deut 1",
        mp2: "Mark 11:1-26",
        ep1: "Deut 2",
        ep2: "Rom 9"
        },
      "February26" => %{
        title: "",
        mp1: "Deut 3",
        mp2: "Mark 11:27-12:12",
        ep1: "Deut 4",
        ep2: "Rom 10"
        },
      "February27" => %{
        title: "",
        mp1: "Deut 5",
        mp2: "Mark 12:13-34",
        ep1: "Deut 6",
        ep2: "Rom 11"
        },
      "February28" => %{
        title: "",
        mp1: "Deut 7",
        mp2: "Mark 12:35-13:13",
        ep1: "Deut 8",
        ep2: "Rom 12"
        },
      "February29" => %{
        title: "",
        mp1: "Deut 9",
        mp2: "Mark 13:14-end",
        ep1: "Deut 10",
        ep2: "Rom 13"
        },
      "March01" => %{
        title: "",
        mp1: "Deut 11",
        mp2: "Mark 14:1-26",
        ep1: "Deut 12",
        ep2: "Rom 14"
        },
      "March02" => %{
        title: "",
        mp1: "Deut 13",
        mp2: "Mark 14:27-52",
        ep1: "Deut 14",
        ep2: "Rom 15"
        },
      "March03" => %{
        title: "",
        mp1: "Deut 15",
        mp2: "Mark 14:53-end",
        ep1: "Deut 16",
        ep2: "Rom 16"
        },
      "March04" => %{
        title: "",
        mp1: "Deut 17",
        mp2: "Mark 15",
        ep1: "Deut 18",
        ep2: "Phil 1:1-11"
        },
      "March05" => %{
        title: "",
        mp1: "Deut 19",
        mp2: "Mark 16",
        ep1: "Deut 20",
        ep2: "Phil 1:12-end"
        },
      "March06" => %{
        title: "",
        mp1: "Deut 21",
        mp2: "Matt 1:1-17",
        ep1: "Deut 22",
        ep2: "Phil 2:1-11"
        },
      "March07" => %{
        title: "",
        mp1: "Deut 23",
        mp2: "Matt 1:18-end",
        ep1: "Deut 24",
        ep2: "Phil 2:12-end"
        },
      "March08" => %{
        title: "",
        mp1: "Deut 25",
        mp2: "Matt 2:1-18",
        ep1: "Deut 26",
        ep2: "Phil 3"
        },
      "March09" => %{
        title: "",
        mp1: "Deut 27",
        mp2: "Matt 2:19-end",
        ep1: "Deut 28",
        ep2: "Phil 4"
        },
      "March10" => %{
        title: "",
        mp1: "Deut 29",
        mp2: "Matt 3",
        ep1: "Deut 30",
        ep2: "Col 1:1-20"
        },
      "March11" => %{
        title: "",
        mp1: "Deut 31",
        mp2: "Matt 4",
        ep1: "Deut 32",
        ep2: "Col 1:21-2:7"
        },
      "March12" => %{
        title: "",
        mp1: "Deut 33",
        mp2: "Matt 5",
        ep1: "Deut 34",
        ep2: "Col 2:8-19"
        },
      "March13" => %{
        title: "",
        mp1: "Josh 1",
        mp2: "Matt 6:1-18",
        ep1: "Josh 2",
        ep2: "Col 2:20-3:11"
        },
      "March14" => %{
        title: "",
        mp1: "Josh 3",
        mp2: "Matt 6:19-end",
        ep1: "Josh 4",
        ep2: "Col 3:12-end"
        },
      "March15" => %{
        title: "",
        mp1: "Josh 5",
        mp2: "Matt 7",
        ep1: "Josh 6",
        ep2: "Col 4"
        },
      "March16" => %{
        title: "",
        mp1: "Josh 7",
        mp2: "Matt 8:1-17",
        ep1: "Josh 8",
        ep2: "Philemon"
        },
      "March17" => %{
        title: "",
        mp1: "Josh 9",
        mp2: "Matt 8:18-end",
        ep1: "Josh 10",
        ep2: "Eph 1:1-14"
        },
      "March18" => %{
        title: "",
        mp1: "Josh 11",
        mp2: "Matt 9:1-17",
        ep1: "Josh 12",
        ep2: "Eph 1:15-end"
        },
      "March19" => %{
        title: "St. Joseph",
        mp1: "Josh 13",
        mp2: "Matt 9:18-34",
        ep1: "Josh 14",
        ep2: "Eph 2:1-10"
        },
      "March20" => %{
        title: "",
        mp1: "Josh 15",
        mp2: "Matt 9:35-10:23",
        ep1: "Josh 16",
        ep2: "Eph 2:11-end"
        },
      "March21" => %{
        title: "",
        mp1: "Josh 17",
        mp2: "Matt 10:24-end",
        ep1: "Josh 18",
        ep2: "Eph 3"
        },
      "March22" => %{
        title: "",
        mp1: "Josh 19",
        mp2: "Matt 11",
        ep1: "Josh 20",
        ep2: "Eph 4:1-16"
        },
      "March23" => %{
        title: "",
        mp1: "Josh 21",
        mp2: "Matt 12:1-21",
        ep1: "Josh 22",
        ep2: "Eph 4:17-30"
        },
      "March24" => %{
        title: "",
        mp1: "Josh 23",
        mp2: "Matt 12:22-end",
        ep1: "Josh 24",
        ep2: "Eph 4:31-5:21"
        },
      "March25" => %{
        title: "Annunciation",
        mp1: "Judg 1",
        mp2: "Matt 13:1-23",
        ep1: "Judg 2",
        ep2: "Eph 5:22-end"
        },
      "March26" => %{
        title: "",
        mp1: "Judg 3",
        mp2: "Matt 13:24-43",
        ep1: "Judg 4",
        ep2: "Eph 6:1-9"
        },
      "March27" => %{
        title: "",
        mp1: "Judg 5",
        mp2: "Matt 13:44-end",
        ep1: "Judg 6",
        ep2: "Eph 6:10-end"
        },
      "March28" => %{
        title: "",
        mp1: "Judg 7",
        mp2: "Matt 14",
        ep1: "Judg 8",
        ep2: "1 Tim 1:1-17"
        },
      "March29" => %{
        title: "",
        mp1: "Judg 9",
        mp2: "Matt 15:1-28",
        ep1: "Judg 10",
        ep2: "1 Tim 1:18-end, 2:1-end"
        },
      "March30" => %{
        title: "",
        mp1: "Judg 11",
        mp2: "Matt 15:29-16:12",
        ep1: "Judg 12",
        ep2: "1 Tim 3"
        },
      "March31" => %{
        title: "",
        mp1: "Judg 13",
        mp2: "Matt 16:13-end",
        ep1: "Judg 14",
        ep2: "1 Tim 4"
        },
      "April01" => %{
        title: "",
        mp1: "Judg 15",
        mp2: "Matt 17:1-23",
        ep1: "Judg 16",
        ep2: "1 Tim 5"
        },
      "April02" => %{
        title: "",
        mp1: "Ruth 1",
        mp2: "Matt 17:24-18:14",
        ep1: "Ruth 2",
        ep2: "1 Tim 6"
        },
      "April03" => %{
        title: "",
        mp1: "Ruth 3",
        mp2: "Matt 18:15-end",
        ep1: "Ruth 4",
        ep2: "Titus 1"
        },
      "April04" => %{
        title: "",
        mp1: "1 Sam 1",
        mp2: "Matt 19:1-15",
        ep1: "1 Sam 2",
        ep2: "Titus 2"
        },
      "April05" => %{
        title: "",
        mp1: "1 Sam 3",
        mp2: "Matt 19:16-20:16",
        ep1: "1 Sam 4",
        ep2: "Titus 3"
        },
      "April06" => %{
        title: "",
        mp1: "1 Sam 5",
        mp2: "Matt 20:17-end",
        ep1: "1 Sam 6",
        ep2: "2 Tim 1"
        },
      "April07" => %{
        title: "",
        mp1: "1 Sam 7",
        mp2: "Matt 21:1-22",
        ep1: "1 Sam 8",
        ep2: "2 Tim 2"
        },
      "April08" => %{
        title: "",
        mp1: "1 Sam 9",
        mp2: "Matt 21:23-end",
        ep1: "1 Sam 10",
        ep2: "2 Tim 3"
        },
      "April09" => %{
        title: "",
        mp1: "1 Sam 11",
        mp2: "Matt 22:1-33",
        ep1: "1 Sam 12",
        ep2: "2 Tim 4"
        },
      "April10" => %{
        title: "",
        mp1: "1 Sam 13",
        mp2: "Matt 22:34-23:12",
        ep1: "1 Sam 14",
        ep2: "Heb 1"
        },
      "April11" => %{
        title: "",
        mp1: "1 Sam 15",
        mp2: "Matt 23:13-end",
        ep1: "1 Sam 16",
        ep2: "Heb 2"
        },
      "April12" => %{
        title: "",
        mp1: "1 Sam 17",
        mp2: "Matt 24:1-28",
        ep1: "1 Sam 18",
        ep2: "Heb 3"
        },
      "April13" => %{
        title: "",
        mp1: "1 Sam 19",
        mp2: "Matt 24:29-end",
        ep1: "1 Sam 20",
        ep2: "Heb 4:1-13"
        },
      "April14" => %{
        title: "",
        mp1: "1 Sam 21",
        mp2: "Matt 25:1-30",
        ep1: "1 Sam 22",
        ep2: "Heb 4:14-5:10"
        },
      "April15" => %{
        title: "",
        mp1: "1 Sam 23",
        mp2: "Matt 25:31-end",
        ep1: "1 Sam 24",
        ep2: "Heb 5:11-end, 6:1-end"
        },
      "April16" => %{
        title: "",
        mp1: "1 Sam 25",
        mp2: "Matt 26:1-30",
        ep1: "1 Sam 26",
        ep2: "Heb 7"
        },
      "April17" => %{
        title: "",
        mp1: "1 Sam 27",
        mp2: "Matt 26:31-56",
        ep1: "1 Sam 28",
        ep2: "Heb 8"
        },
      "April18" => %{
        title: "",
        mp1: "1 Sam 29",
        mp2: "Matt 26:57-end",
        ep1: "1 Sam 30",
        ep2: "Heb 9:1-14"
        },
      "April19" => %{
        title: "",
        mp1: "1 Sam 31",
        mp2: "Matt 27:1-26",
        ep1: "2 Sam 1",
        ep2: "Heb 9:15-end"
        },
      "April20" => %{
        title: "",
        mp1: "2 Sam 2",
        mp2: "Matt 27:27-56",
        ep1: "2 Sam 3",
        ep2: "Heb 10:1-18"
        },
      "April21" => %{
        title: "",
        mp1: "2 Sam 4",
        mp2: "Matt 27:57 & 28",
        ep1: "2 Sam 5",
        ep2: "Heb 10:19-end"
        },
      "April22" => %{
        title: "",
        mp1: "1 Sam 6",
        mp2: "Luke 1:1-23",
        ep1: "2 Sam 7",
        ep2: "Heb 11"
        },
      "April23" => %{
        title: "",
        mp1: "2 Sam 8",
        mp2: "Luke 1:24-56",
        ep1: "2 Sam 9",
        ep2: "Heb 12:1-13"
        },
      "April24" => %{
        title: "",
        mp1: "2 Sam 10",
        mp2: "Luke 1:57-end",
        ep1: "2 Sam 11",
        ep2: "Heb 12:14-end"
        },
      "April25" => %{
        title: "St. Mark",
        mp1: "2 Sam 12",
        mp2: "Luke 2:1-21",
        ep1: "2 Sam 13",
        ep2: "Heb 13"
        },
      "April26" => %{
        title: "",
        mp1: "2 Sam 14",
        mp2: "Luke 2:22-end",
        ep1: "2 Sam 15",
        ep2: "Jas 1"
        },
      "April27" => %{
        title: "",
        mp1: "2 Sam 16",
        mp2: "Luke 3:1-22",
        ep1: "2 Sam 17",
        ep2: "Jas 2:1-13"
        },
      "April28" => %{
        title: "",
        mp1: "2 Sam 18",
        mp2: "Luke 323-end",
        ep1: "2 Sam 19",
        ep2: "Jas 2:14-end"
        },
      "April29" => %{
        title: "",
        mp1: "2 Sam 20",
        mp2: "Luke 4:1-30",
        ep1: "2 Sam 21",
        ep2: "Jas 3"
        },
      "April30" => %{
        title: "",
        mp1: "2 Sam 22",
        mp2: "Luke 4:31-end",
        ep1: "2 Sam 23",
        ep2: "Jas 4"
        },
      "May01" => %{
        title: "Sts. Philip & James",
        mp1: "1 Kings 1",
        mp2: "Luke 5:1-16",
        ep1: "1 Chron 22",
        ep2: "Jas 5"
        },
      "May02" => %{
        title: "",
        mp1: "1 Chron 28",
        mp2: "Luke 5:17-end",
        ep1: "1 Chron 29",
        ep2: "1 Pet 1:1-21"
        },
      "May03" => %{
        title: "",
        mp1: "1 Kings 2",
        mp2: "Luke 6:1-19",
        ep1: "1 Kings 3",
        ep2: "1 Pet 1:22-2:10"
        },
      "May04" => %{
        title: "",
        mp1: "1 Kings 4",
        mp2: "Luke 6:20-38",
        ep1: "1 Kings 5",
        ep2: "1 Pet 2:11-3:7"
        },
      "May05" => %{
        title: "",
        mp1: "1 Kings 6",
        mp2: "Luke 6:39-7:10",
        ep1: "1 Kings 7",
        ep2: "1 Pet 3:8-4:6"
        },
      "May06" => %{
        title: "",
        mp1: "1 Kings 8",
        mp2: "Luke 7:11-35",
        ep1: "1 Kings 9",
        ep2: "1 Pet 4:7-end"
        },
      "May07" => %{
        title: "",
        mp1: "1 Kings 10",
        mp2: "Luke 7:36-end",
        ep1: "1 Kings 11",
        ep2: "1 Pet 5"
        },
      "May08" => %{
        title: "",
        mp1: "1 Kings 12",
        mp2: "Luke 8:1-21",
        ep1: "1 Kings 13",
        ep2: "2 Pet 1"
        },
      "May09" => %{
        title: "",
        mp1: "1 Kings 14",
        mp2: "Luke 8:22-end",
        ep1: "2 Chron 12",
        ep2: "2 Pet 2"
        },
      "May10" => %{
        title: "",
        mp1: "2 Chron 13",
        mp2: "Luke 9:1-17",
        ep1: "2 Chron 14",
        ep2: "2 Pet 3"
        },
      "May11" => %{
        title: "",
        mp1: "2 Chron 15",
        mp2: "Luke 9:18-50",
        ep1: "2 Chron 16",
        ep2: "Jude"
        },
      "May12" => %{
        title: "",
        mp1: "1 Kings 15",
        mp2: "Luke 9:51-end",
        ep1: "1 Kings 16",
        ep2: "1 John 1:1-2:6"
        },
      "May13" => %{
        title: "",
        mp1: "1 Kings 17",
        mp2: "Luke 10:1-24",
        ep1: "1 Kings 18",
        ep2: "1 John 2:7-end"
        },
      "May14" => %{
        title: "",
        mp1: "1 Kings 19",
        mp2: "Luke 10:25-end",
        ep1: "1 Kings 20",
        ep2: "1 John 3:1-12"
        },
      "May15" => %{
        title: "",
        mp1: "1 Kings 21",
        mp2: "Luke 11:1-28",
        ep1: "1 Kings 22",
        ep2: "1 John 3:13-4:6"
        },
      "May16" => %{
        title: "",
        mp1: "2 Chron 20",
        mp2: "Luke 11:29-end",
        ep1: "2 Kings 1",
        ep2: "1 John 4:7-end"
        },
      "May17" => %{
        title: "",
        mp1: "2 Kings 2",
        mp2: "Luke 12:1-34",
        ep1: "2 Kings 3",
        ep2: "1 John 5"
        },
      "May18" => %{
        title: "",
        mp1: "2 Kings 4",
        mp2: "Luke 12:35-53",
        ep1: "2 Kings 5",
        ep2: "2 John"
        },
      "May19" => %{
        title: "",
        mp1: "2 Kings 6",
        mp2: "Luke 12:54-13:9",
        ep1: "2 Kings 7",
        ep2: "3 John"
        },
      "May20" => %{
        title: "",
        mp1: "2 Kings 8",
        mp2: "Luke 13:10-end",
        ep1: "2 Kings 9",
        ep2: "Gal 1"
        },
      "May21" => %{
        title: "",
        mp1: "2 Kings 10",
        mp2: "Luke 14:1-24",
        ep1: "2 Kings 11",
        ep2: "Gal 2"
        },
      "May22" => %{
        title: "",
        mp1: "2 Kings 12",
        mp2: "Luke 14:25-15:10",
        ep1: "2 Kings 13",
        ep2: "Gal 3"
        },
      "May23" => %{
        title: "",
        mp1: "2 Kings 14",
        mp2: "Luke 15:11-end",
        ep1: "2 Chron 26",
        ep2: "Gal 4"
        },
      "May24" => %{
        title: "",
        mp1: "2 Kings 15",
        mp2: "Luke 16",
        ep1: "2 Kings 16",
        ep2: "Gal 5"
        },
      "May25" => %{
        title: "",
        mp1: "2 Kings 17",
        mp2: "Luke 17:1-19",
        ep1: "2 Kings 18",
        ep2: "Gal 6"
        },
      "May26" => %{
        title: "",
        mp1: "2 Chron 30",
        mp2: "Luke 17:20-end",
        ep1: "2 Kings 19",
        ep2: "1 Thess 1"
        },
      "May27" => %{
        title: "",
        mp1: "2 Kings 20",
        mp2: "Luke 18:1-30",
        ep1: "2 Chron 33",
        ep2: "1 Thess 2:1-16"
        },
      "May28" => %{
        title: "",
        mp1: "2 Kings 21",
        mp2: "Luke 18:31-19:10",
        ep1: "2 Kings 22",
        ep2: "1 Thess 2:17-end, 3:1-end"
        },
      "May29" => %{
        title: "",
        mp1: "2 Kings 23",
        mp2: "Luke 19:11-28",
        ep1: "2 Kings 24",
        ep2: "1 Thess 4:1-12"
        },
      "May30" => %{
        title: "",
        mp1: "2 Kings 25",
        mp2: "Luke 19:29-end",
        ep1: "Jer 1",
        ep2: "1 Thess 4:13-5:11"
        },
      "May31" => %{
        title: "Visitation",
        mp1: "Jer 2",
        mp2: "Luke 20:1-26",
        ep1: "Jer 3",
        ep2: "1 Thess 5:12-end"
        },
      "June01" => %{
        title: "",
        mp1: "Jer 4",
        mp2: "Luke 20:27-21:4",
        ep1: "Jer 5",
        ep2: "2 Thess 1"
        },
      "June02" => %{
        title: "",
        mp1: "Jer 6",
        mp2: "Luke 21:5-end",
        ep1: "Jer 7",
        ep2: "2 Thess 2"
        },
      "June03" => %{
        title: "",
        mp1: "Jer 8",
        mp2: "Luke 22:1-38",
        ep1: "Jer 9",
        ep2: "2 Thess 3"
        },
      "June04" => %{
        title: "",
        mp1: "Jer 10",
        mp2: "Luke 22:39-53",
        ep1: "Jer 11",
        ep2: "1 Cor 1:1-25"
        },
      "June05" => %{
        title: "",
        mp1: "Jer 12",
        mp2: "Luke 22:54-end",
        ep1: "Jer 13",
        ep2: "1 Cor 1:26-end, 2:1-end"
        },
      "June06" => %{
        title: "",
        mp1: "Jer 14",
        mp2: "Luke 23:1-25",
        ep1: "Jer 15",
        ep2: "1 Cor 3"
        },
      "June07" => %{
        title: "",
        mp1: "Jer 16",
        mp2: "Luke:23:26-49",
        ep1: "Jer 17",
        ep2: "1 Cor 4:1-17"
        },
      "June08" => %{
        title: "",
        mp1: "Jer 18",
        mp2: "Luke 23:50-24:12",
        ep1: "Jer 19",
        ep2: "1 Cor 4:18-end, 5:1-end"
        },
      "June09" => %{
        title: "",
        mp1: "Jer 20",
        mp2: "Luke 24:13-end",
        ep1: "Jer 21",
        ep2: "1 Cor 6"
        },
      "June10" => %{
        title: "",
        mp1: "Jer 22",
        mp2: "Acts 1:1-14",
        ep1: "Jer 23",
        ep2: "1 Cor 7"
        },
      "June11" => %{
        title: "St. Barnabas",
        mp1: "Jer 24",
        mp2: "Acts 1:15-end",
        ep1: "Jer 25",
        ep2: "1 Cor 8"
        },
      "June12" => %{
        title: "",
        mp1: "Jer 26",
        mp2: "Acts 2:1-21",
        ep1: "Jer 27",
        ep2: "1 Cor 9"
        },
      "June13" => %{
        title: "",
        mp1: "Jer 28",
        mp2: "Acts 2:22-end",
        ep1: "Jer 29",
        ep2: "1 Cor 10"
        },
      "June14" => %{
        title: "",
        mp1: "Jer 30",
        mp2: "Acts 3:1-4:4",
        ep1: "Jer 31",
        ep2: "1 Cor 11"
        },
      "June15" => %{
        title: "",
        mp1: "Jer 32",
        mp2: "Acts 4:5-31",
        ep1: "Jer 33",
        ep2: "1 Cor 12"
        },
      "June16" => %{
        title: "",
        mp1: "Jer 34",
        mp2: "Acts 4:32-5:11",
        ep1: "Jer 35",
        ep2: "1 Cor 13"
        },
      "June17" => %{
        title: "",
        mp1: "Jer 36",
        mp2: "Acts 5:12-end",
        ep1: "Jer 37",
        ep2: "1 Cor 14:1-19"
        },
      "June18" => %{
        title: "",
        mp1: "Jer 38",
        mp2: "Acts 6:1-7:16",
        ep1: "Jer 39",
        ep2: "1 Cor 14:20-end"
        },
      "June19" => %{
        title: "",
        mp1: "Jer 40",
        mp2: "Acts 7:17-34",
        ep1: "Jer 41",
        ep2: "1 Cor 15:1-34"
        },
      "June20" => %{
        title: "",
        mp1: "Jer 42",
        mp2: "Acts 7:35-8:4",
        ep1: "Jer 43",
        ep2: "1 Cor 15:35-end"
        },
      "June21" => %{
        title: "",
        mp1: "Jer 44",
        mp2: "Acts 8:4-25",
        ep1: "Jer 45",
        ep2: "1 Cor 16"
        },
      "June22" => %{
        title: "",
        mp1: "Jer 46",
        mp2: "Acts 8:26-end",
        ep1: "Jer 47",
        ep2: "2 Cor 1:1-2:11"
        },
      "June23" => %{
        title: "",
        mp1: "Jer 48",
        mp2: "Acts 9:1-31",
        ep1: "Jer 49",
        ep2: "2 Cor 2 12-end, 3:1-end"
        },
      "June24" => %{
        title: "Nativity of John the Baptist",
        mp1: "Jer 50",
        mp2: "Acts 9:32-end",
        ep1: "Jer 51",
        ep2: "2 Cor 4"
        },
      "June25" => %{
        title: "",
        mp1: "Jer 52",
        mp2: "Acts 10:1-23",
        ep1: "Lam 1",
        ep2: "2 Cor 5"
        },
      "June26" => %{
        title: "",
        mp1: "Lam 2",
        mp2: "Acts 10:24-end",
        ep1: "Lam 3",
        ep2: "2 Cor 6:1-19"
        },
      "June27" => %{
        title: "",
        mp1: "Lam 4 & 5",
        mp2: "Acts 11:1-18",
        ep1: "Ezek 1",
        ep2: "2 Cor 6:20-end"
        },
      "June28" => %{
        title: "",
        mp1: "Ezek 2",
        mp2: "Acts 11:19-end",
        ep1: "Ezek 3",
        ep2: "2 Cor 7"
        },
      "June29" => %{
        title: "Sts. Peter & Paul",
        mp1: "Ezek 4",
        mp2: "Acts 12:1-24",
        ep1: "Ezek 5",
        ep2: "2 Cor 8"
        },
      "June30" => %{
        title: "",
        mp1: "Ezek 6",
        mp2: "Acts 12:25-13:12",
        ep1: "Ezek 7",
        ep2: "2 Cor 9"
        },
      "July01" => %{
        title: "",
        mp1: "Ezek 8",
        mp2: "Acts 13:13-43",
        ep1: "Ezek 9",
        ep2: "2 Cor 10"
        },
      "July02" => %{
        title: "",
        mp1: "Ezek 10",
        mp2: "Acts 13:44-14:7",
        ep1: "Ezek 11",
        ep2: "2 Cor 11"
        },
      "July03" => %{
        title: "",
        mp1: "Ezek 12",
        mp2: "Acts 14:8-end",
        ep1: "Ezek 13",
        ep2: "2 Cor 12:1-13"
        },
      "July04" => %{
        title: "",
        mp1: "Ezek 14",
        mp2: "Acts 15:1-21",
        ep1: "Ezek 15",
        ep2: "2 Cor 12:14-end, 13:1-end"
        },
      "July05" => %{
        title: "",
        mp1: "Ezek 16",
        mp2: "Acts 15:22-35",
        ep1: "Ezek 17",
        ep2: "Rom 1"
        },
      "July06" => %{
        title: "",
        mp1: "Ezek 18",
        mp2: "Acts 15:36-16:5",
        ep1: "Ezek 19",
        ep2: "Rom 2"
        },
      "July07" => %{
        title: "",
        mp1: "Ezek 20",
        mp2: "Acts 16:6-end",
        ep1: "Ezek 21",
        ep2: "Rom 3"
        },
      "July08" => %{
        title: "",
        mp1: "Ezek 22",
        mp2: "Acts 17:1-15",
        ep1: "Ezek 23",
        ep2: "Rom 4"
        },
      "July09" => %{
        title: "",
        mp1: "Ezek 24",
        mp2: "Acts 17:16-end",
        ep1: "Ezek 25",
        ep2: "Rom 5"
        },
      "July10" => %{
        title: "",
        mp1: "Ezek 26",
        mp2: "Acts 18:1-23",
        ep1: "Ezek 27",
        ep2: "Rom 6"
        },
      "July11" => %{
        title: "",
        mp1: "Ezek 28",
        mp2: "Acts 18:24-19:7",
        ep1: "Ezek 29",
        ep2: "Rom 7"
        },
      "July12" => %{
        title: "",
        mp1: "Ezek 30",
        mp2: "Acts 19:8-20",
        ep1: "Ezek 31",
        ep2: "Rom 8:1-17"
        },
      "July13" => %{
        title: "",
        mp1: "Ezek 32",
        mp2: "Acts 19:21-end",
        ep1: "Ezek 33",
        ep2: "Rom 8:18-end"
        },
      "July14" => %{
        title: "",
        mp1: "Ezek 34",
        mp2: "Acts 20:1-16",
        ep1: "Ezek 35",
        ep2: "Rom 9"
        },
      "July15" => %{
        title: "",
        mp1: "Ezek 36",
        mp2: "Acts 20:17-end",
        ep1: "Ezek 37",
        ep2: "Rom 10"
        },
      "July16" => %{
        title: "",
        mp1: "Ezek 38",
        mp2: "Acts 21:1-16",
        ep1: "Ezek 39",
        ep2: "Rom 11"
        },
      "July17" => %{
        title: "",
        mp1: "Ezek 40",
        mp2: "Acts 21:17-36",
        ep1: "Ezek 41",
        ep2: "Rom 12"
        },
      "July18" => %{
        title: "",
        mp1: "Ezek 42",
        mp2: "Acts 21:37-22:22",
        ep1: "Ezek 43",
        ep2: "Rom 13"
        },
      "July19" => %{
        title: "",
        mp1: "Ezek 44",
        mp2: "Acts 22:23-23:11",
        ep1: "Ezek 45",
        ep2: "Rom 14"
        },
      "July20" => %{
        title: "",
        mp1: "Ezek 46",
        mp2: "Acts 23:12-end",
        ep1: "Ezek 47",
        ep2: "Rom 15"
        },
      "July21" => %{
        title: "",
        mp1: "Ezek 48",
        mp2: "Acts 24:1-23",
        ep1: "Dan 1",
        ep2: "Rom 16"
        },
      "July22" => %{
        title: "St. Mary Magdalene",
        mp1: "Dan 2",
        mp2: "Acts 24:24-25:12",
        ep1: "Dan 3",
        ep2: "Phil 1:1-11"
        },
      "July23" => %{
        title: "",
        mp1: "Dan 4",
        mp2: "Acts 25:13-end",
        ep1: "Dan 5",
        ep2: "Phil 1:12-end"
        },
      "July24" => %{
        title: "",
        mp1: "Dan 6",
        mp2: "Acts 26",
        ep1: "Dan 7",
        ep2: "Phil 2:1-11"
        },
      "July25" => %{
        title: "St. James",
        mp1: "Dan 8",
        mp2: "Acts 27",
        ep1: "Dan 9",
        ep2: "Phil 2:12-end"
        },
      "July26" => %{
        title: "",
        mp1: "Dan 10",
        mp2: "Acts 28:1-15",
        ep1: "Dan 11",
        ep2: "Phil 3"
        },
      "July27" => %{
        title: "",
        mp1: "Dan 12",
        mp2: "Acts 28:16-end",
        ep1: "Esth 1",
        ep2: "Phil 4"
        },
      "July28" => %{
        title: "",
        mp1: "Esth 2",
        mp2: "John 1:1-28",
        ep1: "Esth 3",
        ep2: "John 1:29-end"
        },
      "July29" => %{
        title: "",
        mp1: "Esth 4",
        mp2: "John 2",
        ep1: "Esth 5",
        ep2: "John 3:1-21"
        },
      "July30" => %{
        title: "",
        mp1: "Esth 6",
        mp2: "John 3:22-end",
        ep1: "Esth 7",
        ep2: "John 4:1-26"
        },
      "July31" => %{
        title: "",
        mp1: "Esth 8",
        mp2: "John 4:27-end",
        ep1: "Esth 9",
        ep2: "John 5:1-23"
        },
      "August01" => %{
        title: "",
        mp1: "Esth 10",
        mp2: "Col 1:1-20",
        ep1: "Ezra 1",
        ep2: "John 5:24-end"
        },
      "August02" => %{
        title: "",
        mp1: "Ezra 2",
        mp2: "Col 1:21-2:7",
        ep1: "Ezra 3",
        ep2: "John 6:1-21"
        },
      "August03" => %{
        title: "",
        mp1: "Ezra 4",
        mp2: "Col 2:8-19",
        ep1: "Ezra 5",
        ep2: "John 6:22-40"
        },
      "August04" => %{
        title: "",
        mp1: "Ezra 6",
        mp2: "Col 2:20-3:11",
        ep1: "Ezra 7",
        ep2: "John 6:41-end"
        },
      "August05" => %{
        title: "",
        mp1: "Ezra 8",
        mp2: "Col 3:12-end",
        ep1: "Ezra 9",
        ep2: "John 7:1-24"
        },
      "August06" => %{
        title: "Transfiguration",
        mp1: "Ezra 10",
        mp2: "Col 4",
        ep1: "Neh 1",
        ep2: "John 7:25-end"
        },
      "August07" => %{
        title: "",
        mp1: "Neh 2",
        mp2: "Philemon",
        ep1: "Neh 3",
        ep2: "John 8:1-30"
        },
      "August08" => %{
        title: "",
        mp1: "Neh 4",
        mp2: "Eph 1:1-14",
        ep1: "Neh 5",
        ep2: "John 8:31-end"
        },
      "August09" => %{
        title: "",
        mp1: "Neh 6",
        mp2: "Eph 1:15-end",
        ep1: "Neh 7",
        ep2: "John 9"
        },
      "August10" => %{
        title: "",
        mp1: "Neh 8",
        mp2: "Eph 2:1-10",
        ep1: "Neh 9",
        ep2: "John 10:1-21"
        },
      "August11" => %{
        title: "",
        mp1: "Neh 10",
        mp2: "Eph 2:11-end",
        ep1: "Neh 11",
        ep2: "John 10:22-end"
        },
      "August12" => %{
        title: "",
        mp1: "Neh 12",
        mp2: "Eph 3",
        ep1: "Neh 13",
        ep2: "John 11:1-44"
        },
      "August13" => %{
        title: "",
        mp1: "Hos 1",
        mp2: "Eph 4:1-16",
        ep1: "Hos 2",
        ep2: "John 11:45-end"
        },
      "August14" => %{
        title: "",
        mp1: "Hos 3",
        mp2: "Eph 4:17-30",
        ep1: "Hos 4",
        ep2: "John 12:1-19"
        },
      "August15" => %{
        title: "St. Mary the Virgin",
        mp1: "Hos 5",
        mp2: "Eph 4:31-5:21",
        ep1: "Hos 6",
        ep2: "John 12:20-end"
        },
      "August16" => %{
        title: "",
        mp1: "Hos 7",
        mp2: "Eph 5:22-end",
        ep1: "Hos 8",
        ep2: "John 13"
        },
      "August17" => %{
        title: "",
        mp1: "Hos 9",
        mp2: "Eph 6:1-9",
        ep1: "Hos 10",
        ep2: "John 14:1-14"
        },
      "August18" => %{
        title: "",
        mp1: "Hos 11",
        mp2: "Eph 6:10-end",
        ep1: "Hos 12",
        ep2: "John 14:15-end"
        },
      "August19" => %{
        title: "",
        mp1: "Hos 13",
        mp2: "1 Tim 1:1-17",
        ep1: "Hos 14",
        ep2: "John 15:1-16"
        },
      "August20" => %{
        title: "",
        mp1: "Joel 1",
        mp2: "1 Tim 1:18-end & 2",
        ep1: "Joel 2",
        ep2: "John 15:17-end"
        },
      "August21" => %{
        title: "",
        mp1: "Joel 3",
        mp2: "1 Tim 3",
        ep1: "Amos 1",
        ep2: "John 16:1-15"
        },
      "August22" => %{
        title: "",
        mp1: "Amos 2",
        mp2: "1 Tim 4",
        ep1: "Amos 3",
        ep2: "John 16:16-end"
        },
      "August23" => %{
        title: "",
        mp1: "Amos 4",
        mp2: "1 Tim 5",
        ep1: "Amos 5",
        ep2: "John 17"
        },
      "August24" => %{
        title: "St. Bartholemew",
        mp1: "Amos 6",
        mp2: "1 Tim 6",
        ep1: "Amos 7",
        ep2: "John 18:1-32"
        },
      "August25" => %{
        title: "",
        mp1: "Amos 8",
        mp2: "Titus 1",
        ep1: "Amos 9",
        ep2: "John 18:33-end"
        },
      "August26" => %{
        title: "",
        mp1: "Obadiah",
        mp2: "Titus 2",
        ep1: "Jonah 1",
        ep2: "John 19:1-37"
        },
      "August27" => %{
        title: "",
        mp1: "Jonah 2",
        mp2: "Titus 3",
        ep1: "Jonah 3",
        ep2: "John 19:38-end"
        },
      "August28" => %{
        title: "",
        mp1: "Jonah 4",
        mp2: "2 Tim",
        ep1: "1 Mic",
        ep2: "1 John 20"
        },
      "August29" => %{
        title: "",
        mp1: "Mic 2 2",
        mp2: "Tim 2",
        ep1: "Mic 3",
        ep2: "John 21"
        },
      "August30" => %{
        title: "",
        mp1: "Mic 4 2",
        mp2: "Tim 3",
        ep1: "Mic 5",
        ep2: "Mark 1:1-13"
        },
      "August31" => %{
        title: "",
        mp1: "Mic 6 2",
        mp2: "Tim 4",
        ep1: "Mic 7",
        ep2: "Mark 1:14-31"
        },
      "September01" => %{
        title: "",
        mp1: "Nahum 1",
        mp2: "Heb 1",
        ep1: "Nahum 2",
        ep2: "Mark 1:32-end"
        },
      "September02" => %{
        title: "",
        mp1: "Nahum 3",
        mp2: "Heb 2",
        ep1: "Hab 1",
        ep2: "Mark 2:1-22"
        },
      "September03" => %{
        title: "",
        mp1: "Hab 2",
        mp2: "Heb 3",
        ep1: "Hab 3",
        ep2: "Mark 2:23-3:12"
        },
      "September04" => %{
        title: "",
        mp1: "Zeph 1",
        mp2: "Heb 4:1-13",
        ep1: "Zeph 2",
        ep2: "Mark 3:13-end"
        },
      "September05" => %{
        title: "",
        mp1: "Zeph 3",
        mp2: "Heb 4:14-5:10",
        ep1: "Hag 1",
        ep2: "Mark 4:1-34"
        },
      "September06" => %{
        title: "",
        mp1: "Hag 2",
        mp2: "Heb 5:11-end & 6",
        ep1: "Zech 1",
        ep2: "Mark 4:35-5:20"
        },
      "September07" => %{
        title: "",
        mp1: "Zech 2",
        mp2: "Heb 7",
        ep1: "Zech 3",
        ep2: "Mark 5:21-end"
        },
      "September08" => %{
        title: "",
        mp1: "Zech 4",
        mp2: "Heb 8",
        ep1: "Zech 5",
        ep2: "Mark 6:1-29"
        },
      "September09" => %{
        title: "",
        mp1: "Zech 6",
        mp2: "Heb 9:1-14",
        ep1: "Zech 7",
        ep2: "Mark 6:30-end"
        },
      "September10" => %{
        title: "",
        mp1: "Zech 8",
        mp2: "Heb 9:15-end",
        ep1: "Zech 9",
        ep2: "Mark 7:1-23"
        },
      "September11" => %{
        title: "",
        mp1: "Zech 10",
        mp2: "Heb 10:1-18",
        ep1: "Zech 11",
        ep2: "Mark 7:24-8:10"
        },
      "September12" => %{
        title: "",
        mp1: "Zech 12",
        mp2: "Heb 10:19-end",
        ep1: "Zech 13",
        ep2: "Mark 8:11-end"
        },
      "September13" => %{
        title: "",
        mp1: "Zech 14",
        mp2: "Heb 11",
        ep1: "Mal 1",
        ep2: "Mark 9:1-29"
        },
      "September14" => %{
        title: "Holy Cross",
        mp1: "Mal 2",
        mp2: "Heb 12:1-13",
        ep1: "Mal 3",
        ep2: "Mark 9:30-end"
        },
      "September15" => %{
        title: "",
        mp1: "Mal 4",
        mp2: "Heb 12:14-end",
        ep1: "Prov 1",
        ep2: "Mark 10:1-31"
        },
      "September16" => %{
        title: "",
        mp1: "Prov 2",
        mp2: "Heb 13",
        ep1: "Prov 3",
        ep2: "Mark 10:32-end"
        },
      "September17" => %{
        title: "",
        mp1: "Prov 4",
        mp2: "Jas 1",
        ep1: "Prov 5",
        ep2: "Mark 11:1-26"
        },
      "September18" => %{
        title: "",
        mp1: "Prov 6",
        mp2: "Jas 2:1-13",
        ep1: "Prov 7",
        ep2: "Mark 11:27-12:12"
        },
      "September19" => %{
        title: "",
        mp1: "Prov 8",
        mp2: "Jas 2:14-end",
        ep1: "Prov 9",
        ep2: "Mark 12:13-34"
        },
      "September20" => %{
        title: "",
        mp1: "Prov 10",
        mp2: "Jas 3",
        ep1: "Prov 11",
        ep2: "Mark 12:35-13:13"
        },
      "September21" => %{
        title: "St. Matthew",
        mp1: "Prov 12",
        mp2: "Jas 4",
        ep1: "Prov 13",
        ep2: "Mark 13:14-end"
        },
      "September22" => %{
        title: "",
        mp1: "Prov 14",
        mp2: "Jas 5",
        ep1: "Prov 15",
        ep2: "Mark 14:1-26"
        },
      "September23" => %{
        title: "",
        mp1: "Prov 16",
        mp2: "1 Pet 1:1-21",
        ep1: "Prov 17",
        ep2: "Mark 14:27-52"
        },
      "September24" => %{
        title: "",
        mp1: "Prov 18",
        mp2: "1 Pet 1:22-2:10",
        ep1: "Prov 19",
        ep2: "Mark 14:53-end"
        },
      "September25" => %{
        title: "",
        mp1: "Prov 20",
        mp2: "1 Pet 2:11-3:7",
        ep1: "Prov 21",
        ep2: "Mark 15"
        },
      "September26" => %{
        title: "",
        mp1: "Prov 22",
        mp2: "1 Pet 3:8-4:6",
        ep1: "Prov 23",
        ep2: "Mark 16"
        },
      "September27" => %{
        title: "",
        mp1: "Prov 24",
        mp2: "1 Pet 4:7-end",
        ep1: "Prov 25",
        ep2: "Matt 1:1-17"
        },
      "September28" => %{
        title: "",
        mp1: "Prov 26",
        mp2: "1 Pet 5",
        ep1: "Prov 27",
        ep2: "Matt 1:18-end"
        },
      "September29" => %{
        title: "Holy Michael and All Angels",
        mp1: "Prov 28",
        mp2: "2 Pet 1",
        ep1: "Prov 29",
        ep2: "Matt 2:1-18"
        },
      "September30" => %{
        title: "",
        mp1: "Prov 30",
        mp2: "2 Pet 2",
        ep1: "Prov 31",
        ep2: "Matt 2:19-end"
        },
      "October01" => %{
        title: "",
        mp1: "Job 1",
        mp2: "2 Pet 3",
        ep1: "Job 2",
        ep2: "Matt 3"
        },
      "October02" => %{
        title: "",
        mp1: "Job 3",
        mp2: "Jude",
        ep1: "Job 4",
        ep2: "Matt 4"
        },
      "October03" => %{
        title: "",
        mp1: "Job 5",
        mp2: "1 John 1:1-2:6",
        ep1: "Job 6",
        ep2: "Matt 5"
        },
      "October04" => %{
        title: "",
        mp1: "Job 7",
        mp2: "1 John 2:7-end",
        ep1: "Job 8",
        ep2: "Matt 6:1-18"
        },
      "October05" => %{
        title: "",
        mp1: "Job 9",
        mp2: "1 John 3:1-12",
        ep1: "Job 10",
        ep2: "Matt 6:19-end"
        },
      "October06" => %{
        title: "",
        mp1: "Job 11",
        mp2: "1 John 3:13-4:6",
        ep1: "Job 12",
        ep2: "Matt 7"
        },
      "October07" => %{
        title: "",
        mp1: "Job 13",
        mp2: "1 John 4:7-end",
        ep1: "Job 14",
        ep2: "Matt 8:1-17"
        },
      "October08" => %{
        title: "",
        mp1: "Job 15",
        mp2: "1 John 5",
        ep1: "Job 16",
        ep2: "Matt 8:18-end"
        },
      "October09" => %{
        title: "",
        mp1: "Job 17",
        mp2: "2 John",
        ep1: "Job 18",
        ep2: "Matt 9:1-17"
        },
      "October10" => %{
        title: "",
        mp1: "Job 19",
        mp2: "3 John",
        ep1: "Job 20",
        ep2: "Matt 9:18-34"
        },
      "October11" => %{
        title: "",
        mp1: "Job 21",
        mp2: "Acts 1:1-14",
        ep1: "Job 22",
        ep2: "Matt 9:35-10:23"
        },
      "October12" => %{
        title: "",
        mp1: "Job 23",
        mp2: "Acts 1:15-end",
        ep1: "Job 24",
        ep2: "Matt 10:24-end"
        },
      "October13" => %{
        title: "",
        mp1: "Job 25",
        mp2: "Acts 2:1-21",
        ep1: "Job 26",
        ep2: "Matt 11"
        },
      "October14" => %{
        title: "",
        mp1: "Job 27",
        mp2: "Acts 2:22-end",
        ep1: "Job 28",
        ep2: "Matt 12:1-21"
        },
      "October15" => %{
        title: "",
        mp1: "Job 29",
        mp2: "Acts 3:1-4:4",
        ep1: "Job 30",
        ep2: "Matt 12:22-end"
        },
      "October16" => %{
        title: "",
        mp1: "Job 31",
        mp2: "Acts 4:5-31",
        ep1: "Job 32",
        ep2: "Matt 13:1-23"
        },
      "October17" => %{
        title: "",
        mp1: "Job 33",
        mp2: "Acts 4:32-5:11",
        ep1: "Job 34",
        ep2: "Matt 13:24-43"
        },
      "October18" => %{
        title: "St. Luke",
        mp1: "Job 35",
        mp2: "Acts 5:12-end",
        ep1: "Job 36",
        ep2: "Matt 13:44-end"
        },
      "October19" => %{
        title: "",
        mp1: "Job 37",
        mp2: "Acts 6:1-7:16",
        ep1: "Job 38",
        ep2: "Matt 14"
        },
      "October20" => %{
        title: "",
        mp1: "Job 39",
        mp2: "Acts 7:17-34",
        ep1: "Job 40",
        ep2: "Matt 15:1-28"
        },
      "October21" => %{
        title: "",
        mp1: "Job 41",
        mp2: "Acts 7:35-8:4",
        ep1: "Job 42",
        ep2: "Matt 15:29-16:12"
        },
      "October22" => %{
        title: "",
        mp1: "Baruch 3",
        mp2: "Acts 8:4-25",
        ep1: "Baruch 4",
        ep2: "Matt 16:13-end"
        },
      "October23" => %{
        title: "St. James of Jerusalem",
        mp1: "Baruch 5",
        mp2: "Acts 8:26-end",
        ep1: "Ecclesiasticus 1",
        ep2: "Matt 17:1-23"
        },
      "October24" => %{
        title: "",
        mp1: "Ecclesiasticus 2",
        mp2: "Acts 9:1-31",
        ep1: "Ecclesiasticus 4",
        ep2: "Matt 17:24-18:14"
        },
      "October25" => %{
        title: "",
        mp1: "Ecclesiasticus 6",
        mp2: "Acts 9:32-end",
        ep1: "Ecclesiasticus 7",
        ep2: "Matt 18:15-end"
        },
      "October26" => %{
        title: "",
        mp1: "Ecclesiasticus 9",
        mp2: "Acts 10:1-23",
        ep1: "Ecclesiasticus 10",
        ep2: "Matt 19:1-15"
        },
      "October27" => %{
        title: "",
        mp1: "Ecclesiasticus 11",
        mp2: "Acts 10:24-end",
        ep1: "Ecclesiasticus 14",
        ep2: "Matt 19:16-20:16"
        },
      "October28" => %{
        title: "Sts. Simon & Jude",
        mp1: "Ecclesiasticus 15",
        mp2: "Acts 11:1-18",
        ep1: "Ecclesiasticus 17",
        ep2: "Matt 20:17-end"
        },
      "October29" => %{
        title: "",
        mp1: "Ecclesiasticus 18",
        mp2: "Acts 11:19-end",
        ep1: "Ecclesiasticus 21",
        ep2: "Matt 21:1-22"
        },
      "October30" => %{
        title: "",
        mp1: "Ecclesiasticus 28",
        mp2: "Acts 12:1-24",
        ep1: "Ecclesiasticus 29",
        ep2: "Matt 21:23-end"
        },
      "October31" => %{
        title: "",
        mp1: "Ecclesiasticus 34",
        mp2: "Acts 12:25-13:12",
        ep1: "Ecclesiasticus 38",
        ep2: "Matt 22:1-33"
        },
      "November01" => %{
        title: "All Saints",
        mp1: "Ecclesiasticus 39",
        mp2: "Acts 13:13-43",
        ep1: "Ecclesiasticus 43",
        ep2: "Matt 22:34-23:12"
        },
      "November02" => %{
        title: "",
        mp1: "Ecclesiasticus 44",
        mp2: "Acts 13:44-14:7",
        ep1: "Ecclesiasticus 45",
        ep2: "Matt 23:13-end"
        },
      "November03" => %{
        title: "",
        mp1: "Ecclesiasticus 46",
        mp2: "Acts 14:8-end",
        ep1: "Ecclesiasticus 47",
        ep2: "Matt 24:1-28"
        },
      "November04" => %{
        title: "",
        mp1: "Ecclesiasticus 48",
        mp2: "Acts 15:1-21",
        ep1: "Ecclesiasticus 49",
        ep2: "Matt 24:29-end"
        },
      "November05" => %{
        title: "",
        mp1: "Ecclesiasticus 50",
        mp2: "Acts 15:22-35",
        ep1: "Ecclesiasticus 51",
        ep2: "Matt 25:1-30"
        },
      "November06" => %{
        title: "",
        mp1: "Prayer of Manasseh",
        mp2: "Acts 15:36-16:5",
        ep1: "Judith 4",
        ep2: "Matt 25:31-end"
        },
      "November07" => %{
        title: "",
        mp1: "Judith 8",
        mp2: "Acts 16:6-end",
        ep1: "Judith 9",
        ep2: "Matt 26:1-30"
        },
      "November08" => %{
        title: "",
        mp1: "Judith 10",
        mp2: "Acts 17:1-15",
        ep1: "Judith 11",
        ep2: "Matt 26:31-56"
        },
      "November09" => %{
        title: "",
        mp1: "Judith 12",
        mp2: "Acts 17:16-end",
        ep1: "Judith 13",
        ep2: "Matt 26:57-end"
        },
      "November10" => %{
        title: "",
        mp1: "Judith 14",
        mp2: "Acts 18:1-23",
        ep1: "Judith 15",
        ep2: "Matt 27:1-26"
        },
      "November11" => %{
        title: "",
        mp1: "Judith 16",
        mp2: "Acts 18:24-19:7",
        ep1: "Susanna",
        ep2: "Matt 27:27-56"
        },
      "November12" => %{
        title: "",
        mp1: "Bel and the Dragon",
        mp2: "Acts 19:8-20 1",
        ep1: "Maccabees 1",
        ep2: "Matt 27:57-end, 28:1-end"
        },
      "November13" => %{
        title: "",
        mp1: "2 Maccabees 6",
        mp2: "Acts 19:21-end",
        ep1: "2 Maccabees 7",
        ep2: "Luke 1:1-23"
        },
      "November14" => %{
        title: "",
        mp1: "2 Maccabees 8",
        mp2: "Acts 20:1-16",
        ep1: "2 Maccabees 9",
        ep2: "Luke 1:24-56"
        },
      "November15" => %{
        title: "",
        mp1: "2 Maccabees 10",
        mp2: "Acts 20:17-end",
        ep1: "1 Maccabees 7",
        ep2: "Luke 1:57-end"
        },
      "November16" => %{
        title: "",
        mp1: "1 Maccabees 9",
        mp2: "Acts 21:1-16",
        ep1: "1 Maccabees 13",
        ep2: "Luke 2:1-21"
        },
      "November17" => %{
        title: "",
        mp1: "1 Maccabees 14",
        mp2: "Acts 21:17-36",
        ep1: "Wisdom 1",
        ep2: "Luke 2:22-end"
        },
      "November18" => %{
        title: "",
        mp1: "Wisdom 2",
        mp2: "Acts 21:37-22:22",
        ep1: "Wisdom 3",
        ep2: "Luke 3:1-22"
        },
      "November19" => %{
        title: "",
        mp1: "Wisdom 4",
        mp2: "Acts 22:23-23:11",
        ep1: "Wisdom 5",
        ep2: "Luke 3:23-end"
        },
      "November20" => %{
        title: "",
        mp1: "Wisdom 6",
        mp2: "Acts 23:12-end",
        ep1: "Wisdom 7",
        ep2: "Luke 4:1-30"
        },
      "November21" => %{
        title: "",
        mp1: "Wisdom 8",
        mp2: "Acts 24:1-23",
        ep1: "Wisdom 9",
        ep2: "Luke 4:31-end"
        },
      "November22" => %{
        title: "",
        mp1: "Wisdom 10",
        mp2: "Acts 24:24-25:12",
        ep1: "Wisdom 11",
        ep2: "Luke 5:1-16"
        },
      "November23" => %{
        title: "",
        mp1: "Wisdom 12",
        mp2: "Acts 25:13-end",
        ep1: "Wisdom 13",
        ep2: "Luke 5:17-end"
        },
      "November24" => %{
        title: "",
        mp1: "Wisdom 14",
        mp2: "Acts 26",
        ep1: "Wisdom 15",
        ep2: "Luke 6:1-19"
        },
      "November25" => %{
        title: "",
        mp1: "Song of Songs 1",
        mp2: "Acts 27",
        ep1: "Song of Songs 2",
        ep2: "Luke 6:20-38"
        },
      "November26" => %{
        title: "",
        mp1: "Song of Songs 3",
        mp2: "Acts 28:1-15",
        ep1: "Song of Songs 4",
        ep2: "Luke 6:39-7:10"
        },
      "November27" => %{
        title: "",
        mp1: "Song of Songs 5",
        mp2: "Acts 28:16-end",
        ep1: "Song of Songs 6",
        ep2: "Luke 7:11-35"
        },
      "November28" => %{
        title: "",
        mp1: "Song of Songs 7",
        mp2: "Rev 1",
        ep1: "Song of Songs 8",
        ep2: "Luke 7:36-end"
        },
      "November29" => %{
        title: "",
        mp1: "Isa 1",
        mp2: "Rev 2:1-17",
        ep1: "Isa 2",
        ep2: "Luke 8:1-21"
        },
      "November30" => %{
        title: "St. Andrew",
        mp1: "Isa 3",
        mp2: "Rev 2:18-3:6",
        ep1: "Isa 4",
        ep2: "Luke 8:22-end"
        },
      "December01" => %{
        title: "",
        mp1: "Isa 5",
        mp2: "Rev 3:7-end",
        ep1: "Isa 6",
        ep2: "Luke 9:1-17"
        },
      "December02" => %{
        title: "",
        mp1: "Isa 7",
        mp2: "Rev 4",
        ep1: "Isa 8",
        ep2: "Luke 9:18-50"
        },
      "December03" => %{
        title: "",
        mp1: "Isa 9",
        mp2: "Rev 5",
        ep1: "Isa 10",
        ep2: "Luke 9:51-end"
        },
      "December04" => %{
        title: "",
        mp1: "Isa 11",
        mp2: "Rev 6",
        ep1: "Isa 12",
        ep2: "Luke 10:1-24"
        },
      "December05" => %{
        title: "",
        mp1: "Isa 13",
        mp2: "Rev 7",
        ep1: "Isa 14",
        ep2: "Luke 10:25-end"
        },
      "December06" => %{
        title: "",
        mp1: "Isa 15",
        mp2: "Rev 8",
        ep1: "Isa 16",
        ep2: "Luke 11:1-28"
        },
      "December07" => %{
        title: "",
        mp1: "Isa 17",
        mp2: "Rev 9",
        ep1: "Isa 18",
        ep2: "Luke 11:29-end"
        },
      "December08" => %{
        title: "",
        mp1: "Isa 19",
        mp2: "Rev 10",
        ep1: "Isa 20",
        ep2: "Luke 12:1-34"
        },
      "December09" => %{
        title: "",
        mp1: "Isa 21",
        mp2: "Rev 11",
        ep1: "Isa 22",
        ep2: "Luke 12:35-53"
        },
      "December10" => %{
        title: "",
        mp1: "Isa 23",
        mp2: "Rev 12",
        ep1: "Isa 24",
        ep2: "Luke 12:54-13:9"
        },
      "December11" => %{
        title: "",
        mp1: "Isa 25",
        mp2: "Rev 13",
        ep1: "Isa 26",
        ep2: "Luke 13:10-end"
        },
      "December12" => %{
        title: "",
        mp1: "Isa 27",
        mp2: "Rev 14",
        ep1: "Isa 28",
        ep2: "Luke 14:1-24"
        },
      "December13" => %{
        title: "",
        mp1: "Isa 29",
        mp2: "Rev 15",
        ep1: "Isa 30",
        ep2: "Luke 14:25-15:10"
        },
      "December14" => %{
        title: "",
        mp1: "Isa 31",
        mp2: "Rev 16",
        ep1: "Isa 32",
        ep2: "Luke 15:11-end"
        },
      "December15" => %{
        title: "",
        mp1: "Isa 33",
        mp2: "Rev 17",
        ep1: "Isa 34",
        ep2: "Luke 16"
        },
      "December16" => %{
        title: "",
        mp1: "Isa 35",
        mp2: "Rev 18",
        ep1: "Isa 36",
        ep2: "Luke 17:1-19"
        },
      "December17" => %{
        title: "",
        mp1: "Isa 37",
        mp2: "Rev 19",
        ep1: "Isa 38",
        ep2: "Luke 17:20-end"
        },
      "December18" => %{
        title: "",
        mp1: "Isa 39",
        mp2: "Rev 20",
        ep1: "Isa 40",
        ep2: "Luke 18:1-30"
        },
      "December19" => %{
        title: "",
        mp1: "Isa 41",
        mp2: "Rev 21:1-14",
        ep1: "Isa 42",
        ep2: "Luke 18:31-19:10"
        },
      "December20" => %{
        title: "",
        mp1: "Isa 43",
        mp2: "Rev 21:15-22:5",
        ep1: "Isa 44",
        ep2: "Luke 19:11-28"
        },
      "December21" => %{
        title: "St. Thomas",
        mp1: "Isa 45",
        mp2: "Rev 22:6-end",
        ep1: "Isa 46",
        ep2: "Luke 19:29-end"
        },
      "December22" => %{
        title: "",
        mp1: "Isa 47",
        mp2: "Phil 1:1-11",
        ep1: "Isa 48",
        ep2: "Luke 20:1-26"
        },
      "December23" => %{
        title: "",
        mp1: "Isa 49",
        mp2: "Phil 1:12-end",
        ep1: "Isa 50",
        ep2: "Luke 20:27-21:4"
        },
      "December24" => %{
        title: "",
        mp1: "Isa 51",
        mp2: "Phil 2",
        ep1: "Isa 52",
        ep2: "Luke 21:5-end"
        },
      "December25" => %{
        title: "Christmas Day",
        mp1: "Isa 53",
        mp2: "Phil 3",
        ep1: "Isa 54",
        ep2: "Luke 22:1-38"
        },
      "December26" => %{
        title: "St. St
        ephen",
        mp1: "Isa 55",
        mp2: "Phil 4",
        ep1: "Isa 56",
        ep2: "Luke 22:39-53"
        },
      "December27" => %{
        title: "St. John",
        mp1: "Isa 57",
        mp2: "1 John 1",
        ep1: "Isa 58",
        ep2: "Luke 22:54-end"
        },
      "December28" => %{
        title: "Holy Innocents",
        mp1: "Isa 59",
        mp2: "1 John 2",
        ep1: "Isa 60",
        ep2: "Luke 23:1-25"
        },
      "December29" => %{
        title: "",
        mp1: "Isa 61",
        mp2: "1 John 3",
        ep1: "Isa 62",
        ep2: "Luke:23:26-49"
        },
      "December30" => %{
        title: "",
        mp1: "Isa 63",
        mp2: "1 John 4",
        ep1: "Isa 64",
        ep2: "Luke 23:50-24:12"
        },
      "December31" => %{
        title: "",
        mp1: "Isa 65",
        mp2: "1 John 5",
        ep1: "Isa 66",
        ep2: "Luke 24:13-end"
      }
    } # end of model
  end
end