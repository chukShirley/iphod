require IEx

defmodule DailyReading do
  import IphodWeb.Gettext, only: [dgettext: 2]
  # import Psalms, only: [morning: 1, evening: 1]
  import SundayReading, only: [collect_today: 1, colors: 1]
  import Lityear, only: [to_season: 1]
  use Timex
  def start_link, do: Agent.start_link(fn -> build() end, name: __MODULE__)
  def identity(), do: Agent.get(__MODULE__, & &1)

  def mp_body(date, versions_map \\ %{mpp: "BCP", mp1: "ESV", mp2: "ESV"}) do
    mp = mp_today(date)

    [:mp1, :mp2, :mpp]
    |> Enum.reduce(mp, fn r, acc ->
      acc |> Map.put(r, BibleText.lesson_with_body(mp[r], versions_map[r]))
    end)
    |> Map.put(:show, true)
    |> Map.put(:collect, collect_today(date))
  end

  def ep_body(date, versions_map \\ %{epp: "BCP", ep1: "ESV", ep2: "ESV"}) do
    ep = ep_today(date)

    [:ep1, :ep2, :epp]
    |> Enum.reduce(ep, fn r, acc ->
      acc |> Map.put(r, BibleText.lesson_with_body(ep[r], versions_map[r]))
    end)
    |> Map.put(:show, true)
    |> Map.put(:collect, collect_today(date))
  end

  def opening_sentence(mpep, date) do
    # set true for mpep
    {season, _wk, _lityr, _date} = Lityear.to_season(date, true)
    _opening_sentence(mpep, season) |> pick_one(date)
  end

  def _opening_sentence(mpep, "ashWednesday"), do: identity()["#{mpep}_opening"]["lent"]
  def _opening_sentence(mpep, "palmSunday"), do: identity()["#{mpep}_opening"]["lent"]
  def _opening_sentence(mpep, "holyWeek"), do: identity()["#{mpep}_opening"]["lent"]
  def _opening_sentence(mpep, "easterDay"), do: identity()["#{mpep}_opening"]["easter"]
  def _opening_sentence(mpep, "easterWeek"), do: identity()["#{mpep}_opening"]["easter"]
  def _opening_sentence(mpep, "ascension"), do: identity()["#{mpep}_opening"]["easter"]
  def _opening_sentence(mpep, "theEpiphany"), do: identity()["#{mpep}_opening"]["epiphany"]
  def _opening_sentence(mpep, season), do: identity()["#{mpep}_opening"][season]

  def antiphon(date) do
    {season, _wk, _lityr, _date} = Lityear.to_season(date, true)
    _antiphon(season) |> pick_one(date)
  end

  def _antiphon("ashWednesday"), do: identity()["antiphon"]["lent"]
  def _antiphon("holyWeek"), do: identity()["antiphon"]["lent"]
  def _antiphon("goodFriday"), do: identity()["antiphon"]["lent"]
  def _antiphon("easterWeek"), do: identity()["antiphon"]["easter"]
  def _antiphon("ascension"), do: identity()["antiphon"]["easter"]
  def _antiphon("theEpiphany"), do: identity()["antiphon"]["epiphany"]
  def _antiphon(season), do: identity()["antiphon"][season]

  def pick_one(list, date) do
    if list == nil, do: IEx.pry()
    len = length(list)
    at = rem(Timex.day(date), len)
    Enum.at(list, at)
  end

  def readings(date) do
    day = date |> Timex.format!("%B%d", :strftime)
    dayName = date |> Timex.format!("%A", :strftime)
    {season, wk, _litYr, _date} = date |> to_season
    r = identity()[day]
    if !r, do: IEx.pry()

    %{
      colors: SundayReading.colors(date),
      date: date |> Timex.format!("%A %B %e, %Y", :strftime),
      day: dayName,
      ep1: %{
        body: "",
        # id: vssToId(r.ep1),
        read: r.ep1,
        section: "ep1",
        show: false,
        show_fn: true,
        show_vn: true,
        style: "req",
        version: ""
      },
      ep2: %{
        body: "",
        # id: vssToId(r.ep2),
        read: r.ep2,
        section: "ep2",
        show: false,
        show_fn: true,
        show_vn: true,
        style: "req",
        version: ""
      },
      epp: mapPsalmsToWithBody("ep", date),
      mp1: %{
        body: "",
        # id: vssToId(r.mp1),
        read: r.mp1,
        section: "mp1",
        show: false,
        show_fn: true,
        show_vn: true,
        style: "req",
        version: ""
      },
      mp2: %{
        body: "",
        # id: vssToId(r.mp2),
        read: r.mp2,
        section: "mp2",
        show: false,
        show_fn: true,
        show_vn: true,
        style: "req",
        version: ""
      },
      mpp: mapPsalmsToWithBody("mp", date),
      season: season,
      title: if(r.title |> String.length() == 0, do: dayName, else: r.title),
      week: wk
    }
  end

  def day_of_week({"christmas", "1", _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    dec_n = date |> Timex.format!("{D}")

    cond do
      dec_n == "24" ->
        {"christmas", "1", "christmasEve", date}

      dec_n == "25" ->
        {"christmas", "1", "christmasDay", date}

      dow == "Sunday" ->
        {"christmas", "1", "Sunday", date}

      dec_n == "26" ->
        {"christmas", "1", "stStephen", date}

      dec_n == "27" ->
        {"christmas", "1", "stJohn", date}

      dec_n == "28" ->
        {"christmas", "1", "holyInnocents", date}

      dec_n == "29" ->
        {"christmas", "1", "Dec29", date}

      dec_n == "30" ->
        {"christmas", "1", "Dec30", date}

      dec_n == "31" ->
        {"christmas", "1", "Dec31", date}

      # Jan 1
      dec_n == "1" ->
        {"christmas", "1", "octaveChristmas", date}

      # these date can also fall in Christmas 1
      dec_n == "2" ->
        {"christmas", "2", "Jan02", date}

      # these date can also fall in Christmas 1
      dec_n == "3" ->
        {"christmas", "2", "Jan03", date}

      # these date can also fall in Christmas 1
      dec_n == "4" ->
        {"christmas", "2", "Jan04", date}

      # these date can also fall in Christmas 1
      dec_n == "5" ->
        {"christmas", "2", "Jan05", date}

      # these date can also fall in Christmas 1
      dec_n == "6" ->
        {"epiphany", "0", dow, date}

      true ->
        dow
    end
  end

  def day_of_week({"christmas", "2", _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    jan_n = date |> Timex.format!("{D}")

    cond do
      dow == "Sunday" -> {"christmas", "2", "Sunday", date}
      jan_n == "2" -> {"christmas", "2", "Jan02", date}
      jan_n == "3" -> {"christmas", "2", "Jan03", date}
      jan_n == "4" -> {"christmas", "2", "Jan04", date}
      jan_n == "5" -> {"christmas", "2", "Jan05", date}
      jan_n == "6" -> {"epiphany", "0", dow, date}
      jan_n == "7" -> {"epiphany", "0", dow, date}
      jan_n == "8" -> {"epiphany", "0", dow, date}
      jan_n == "9" -> {"epiphany", "0", dow, date}
      jan_n == "10" -> {"epiphany", "0", dow, date}
      jan_n == "11" -> {"epiphany", "0", dow, date}
      true -> dow
    end
  end

  def day_of_week({"redLetter", _wk, _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    {new_season, new_wk, _litYr, _date} = date |> Lityear.last_sunday()
    {new_season, new_wk, dow, date}
  end

  def day_of_week({season, wk, _litYr, date}) do
    dow = date |> Timex.format!("{WDfull}")
    {season, wk, dow, date}
  end

  def lesson(date, section, ver) do
    readings(date)[section |> String.to_atom()]
    |> BibleText.lesson_with_body(ver)
  end

  def mapPsalmsToWithBody(mpep, date) do
    day = date.day

    {section, pss} =
      if mpep == "mp", do: {"mpp", Psalms.morning(day)}, else: {"epp", Psalms.evening(day)}

    pss
    |> Enum.map(fn ps ->
      if ps |> is_tuple do
        {p, vsStart, vsEnd} = ps

        %{
          body: "",
          id: "Psalm_#{p}_#{vsStart}_#{vsEnd}",
          read: "Psalm #{p}:#{vsStart}-#{vsEnd}",
          section: section,
          style: "req",
          show: false,
          show_fn: true,
          show_vn: true,
          version: ""
        }
      else
        %{
          body: "",
          id: "Psalm_#{ps}",
          read: "Psalm #{ps}",
          section: section,
          style: "req",
          show: false,
          show_fn: true,
          show_vn: true,
          version: ""
        }
      end
    end)
  end

  #   defp vssToId(vss) do
  #     Regex.replace(~r/[\s\.\:\,]/, vss, "_")
  #   end

  defp to_lessons(map) do
    map
    |> Map.update(:mp1, [], fn el -> _to_lessons_for("mp1", el) end)
    |> Map.update(:mp2, [], fn el -> _to_lessons_for("mp2", el) end)
    |> Map.update(:mpp, [], fn el -> _to_lessons_for("mpp", el) end)
    |> Map.update(:ep1, [], fn el -> _to_lessons_for("ep1", el) end)
    |> Map.update(:ep2, [], fn el -> _to_lessons_for("ep2", el) end)
    |> Map.update(:epp, [], fn el -> _to_lessons_for("epp", el) end)
  end

  #   defp _to_lessons_for(_section, []), do: []

  #   defp _to_lessons_for(section, list) do
  #     list |> Enum.map(fn el -> _add_keys_for(section, el) end)
  #   end

  #   defp _add_keys_for(section, map) do
  #     if map |> Map.has_key?(:read) do
  #       map |> Map.put_new(:id, vssToId(map.read))
  #     else
  #       map
  #     end
  #     |> Map.put_new(:section, section)
  #     |> Map.put_new(:body, "")
  #     |> Map.put_new(:show, false)
  #     |> Map.put_new(:show_fn, true)
  #     |> Map.put_new(:show_vn, true)
  #     |> Map.put_new(:version, "")
  #   end

  def mp_today(date) do
    r = readings(date)

    day =
      if r.title |> String.length() == 0, do: date |> Timex.format("%A", :strftime), else: r.title

    {season, week, _litYr, _date} = date |> to_season

    %{
      colors: colors(date),
      date: r.date,
      day: day,
      season: season,
      title: r.title,
      week: week,
      mp1: r.mp1,
      mp2: r.mp2,
      mpp: r.mpp,
      show: false,
      sectionUpdate: %{section: "", version: "", ref: ""}
    }

    # get the ESV text, put it the body for   mp1,  mp2,   mpp
  end

  def ep_today(date) do
    r = readings(date)

    day =
      if r.title |> String.length() == 0, do: date |> Timex.format("%A", :strftime), else: r.title

    {season, week, _litYr, _date} = date |> to_season

    %{
      colors: colors(date),
      date: date,
      day: day,
      season: season,
      title: r.title,
      week: week,
      ep1: r.ep1,
      ep2: r.ep2,
      epp: r.epp,
      show: false,
      sectionUpdate: %{section: "", version: "", ref: ""}
    }

    # get the ESV text, put it the body for   ep1,  ep2,   epp
  end

  def reading_map("mp", date) do
    r = readings(date)

    %{
      mp1: r.mp1.read |> Enum.map(& &1.read),
      mp2: r.mp2.read |> Enum.map(& &1.read),
      mpp: r.mpp |> Enum.map(& &1.read)
    }
  end

  def reading_map("ep", date) do
    r = readings(date)

    %{
      ep1: r.ep1.read |> Enum.map(& &1.read),
      ep2: r.ep2.read |> Enum.map(& &1.read),
      epp: r.epp |> Enum.map(& &1.read)
    }
  end

  def title_for(date) do
    {rldDate, rldName} = Lityear.next_holy_day(date)
    if date == rldDate, do: Lityear.hd_title(rldName), else: readings(date).title
  end

  def build do
    %{
      "antiphon" => %{
        "advent" => [
          dgettext("antiphon", "Our King and Savior now draws near: O come, let us adore him.")
        ],
        "christmas" => [
          dgettext(
            "antiphon",
            "Alleluia, to us a child is born: O come, let us adore him. Alleluia."
          )
        ],
        "epiphany" => [
          dgettext("antiphon", "The Lord has shown forth his glory: O come, let us adore him.")
        ],
        "lent" => [
          dgettext(
            "antiphon",
            "The Lord is full of compassion and mercy: O come, let us adore him."
          )
        ],
        "palmSunday" => [
          dgettext(
            "antiphon",
            "The Lord is full of compassion and mercy: O come, let us adore him."
          )
        ],
        "easterDay" => [
          dgettext(
            "antiphon",
            "Alleluia. The Lord is risen indeed: O come, let us adore him. Alleluia."
          )
        ],
        "easter" => [
          dgettext(
            "antiphon",
            "Alleluia. The Lord is risen indeed: O come, let us adore him. Alleluia."
          )
        ],
        "proper" => [
          dgettext(
            "antiphon",
            "The earth is the Lord's for he made it: O Come let us adore him."
          ),
          dgettext(
            "antiphon",
            "Worship the Lord in the beauty of holiness: O Come let us adore him."
          ),
          dgettext("antiphon", "The mercy of the Lord is everlasting: O Come let us adore him."),
          dgettext(
            "antiphon",
            "Worship the Lord in the beauty of holiness: O Come let us adore him."
          )
        ],
        "ascension" => [
          dgettext(
            "antiphon",
            "Alleluia. Christ the Lord has ascended into heaven: O come, let us adore him. Alleluia."
          )
        ],
        "pentecost" => [
          dgettext(
            "antiphon",
            "Alleluia. The Spirit of the Lord renews the face of the earth: O come, let us adore him. Alleluia."
          )
        ],
        "trinity" => [
          dgettext("antiphon", "Father, Son and Holy Spirit, one God: O come, let us adore him.")
        ],
        "incarnation" => [
          dgettext(
            "antiphon",
            "The Word was made flesh and dwelt among us: O come, let us adore him."
          )
        ],
        "saints" => [
          dgettext("antiphon", "The Lord is glorious in his saints: O come, let us adore him.")
        ]
      },
      "mp_opening" => %{
        "advent" => [
          {
            dgettext(
              "mp_opening",
              "In the wilderness prepare the way of the Lord; make straight in the desert a highway for our God."
            ),
            dgettext("mp_opening", "Isaiah 40:3")
          }
        ],
        "christmas" => [
          {
            dgettext(
              "mp_opening",
              "Fear not, for behold, I bring you good news of a great joy that will be for all people. For unto you is born this day in the city of David a Savior, who is Christ the Lord."
            ),
            dgettext("mp_opening", "Luke 2:10-11")
          }
        ],
        "epiphany" => [
          {
            dgettext(
              "mp_opening",
              "For from the rising of the sun to its setting my name will be great among the nations, and in every place incense will be offered to my name, and a pure offering. For my name will be great among the nations, says the Lord of hosts."
            ),
            dgettext("mp_opening", "Malachi 1:11")
          }
        ],
        "lent" => [
          {
            dgettext("mp_opening", "Repent, for the kingdom of heaven is at hand."),
            dgettext("mp_opening", "Matthew 3:2")
          }
        ],
        "goodFriday" => [
          {
            dgettext(
              "mp_opening",
              "Is it nothing to you, all you who pass by? Look and see if there is any sorrow like my sorrow, which was brought upon me, which the Lord inflicted on the day of his fierce anger."
            ),
            dgettext("mp_opening", "Lamentations 1:12")
          }
        ],
        "easter" => [
          {
            dgettext("mp_opening", "Christ is risen! The Lord is risen indeed!"),
            dgettext("mp_opening", "Mark 16:6 and Luke 24:34")
          }
        ],
        "ascension" => [
          {
            dgettext(
              "mp_opening",
              "Since then we have a great high priest who has passed through the heavens, Jesus, the Son of God, let us hold fast our confession. Let us then with confidence draw near to the throne of grace, that we may receive mercy and find grace to help in time of need."
            ),
            dgettext("mp_opening", "Hebrews 4:14, 16")
          }
        ],
        "pentecost" => [
          {
            dgettext(
              "mp_opening",
              "You will receive power when the Holy Spirit has come upon you, and you will be my witnesses in Jerusalem and in all Judea and Samaria, and to the end of the earth."
            ),
            dgettext("mp_opening", "Acts 1:8")
          }
        ],
        "trinity" => [
          {
            dgettext(
              "mp_opening",
              "Holy, holy, holy, is the Lord God Almighty, who was and is and is to come!"
            ),
            dgettext("mp_opening", "Revelation 4:8")
          }
        ],
        "thanksgiving" => [
          {
            dgettext(
              "mp_opening",
              "Honor the Lord with your wealth and with the firstfruits of all your produce; then your barns will be filled with plenty, and your vats will be bursting with wine."
            ),
            dgettext("mp_opening", "Proverbs 3:9-10")
          }
        ],
        "proper" => [
          {dgettext(
             "mp_opening",
             "The Lord is in his holy temple; let all the earth keep silence before him."
           ), dgettext("mp_opening", "Habakkuk 2:20")},
          {dgettext(
             "mp_opening",
             "I was glad when they said to me, “Let us go to the house of the Lord!”"
           ), dgettext("mp_opening", "Psalm 122:1")},
          {dgettext(
             "mp_opening",
             "Let the words of my mouth and the meditation of my heart be acceptable in your sight, O Lord, my rock and my redeemer."
           ), dgettext("mp_opening", "Psalm 19:14")},
          {dgettext(
             "mp_opening",
             "Send out your light and your truth; let them lead me; let them bring me to your holy hill and to your dwelling!"
           ), dgettext("mp_opening", "Psalm 43:3")},
          {dgettext(
             "mp_opening",
             "For thus says the One who is high and lifted up, who inhabits eternity, whose name is Holy: “I dwell in the high and holy place, and also with him who is of a contrite and lowly spirit, to revive the spirit of the lowly, and to revive the heart of the contrite.”"
           ), dgettext("mp_opening", "Isaiah 57:15")},
          {dgettext(
             "mp_opening",
             "The hour is coming, and is now here, when the true worshipers will worship the Father in spirit and truth, for the Father is seeking such people to worship him."
           ), dgettext("mp_opening", "John 4:23")},
          {dgettext(
             "mp_opening",
             "Grace to you and peace from God our Father and the Lord Jesus Christ."
           ), dgettext("mp_opening", "Philippians 1:2")}
        ]
      },
      "ep_opening" => %{
        "advent" => [
          {
            dgettext("ep_opening", """
              Therefore stay awake – for you do not know when the master of the
            house will come, in the evening, or at midnight, or when the cock
            crows, or in the morning – lest he come suddenly and find you asleep.
            """),
            dgettext("ep_opening", "Mark 13:35-36")
          }
        ],
        "christmas" => [
          {
            dgettext("ep_opening", """
              Behold, the dwelling place of God is with man. He will dwell with
            them, and they will be his people, and God himself will be with them
            as their God.
            """),
            dgettext("ep_opening", "Revelation 21:3")
          }
        ],
        "epiphany" => [
          {
            dgettext(
              "ep_opening",
              "Nations shall come to your light, and kings to the brightness of your rising."
            ),
            dgettext("ep_opening", "Isaiah 60:3")
          }
        ],
        "lent" => [
          {
            dgettext("ep_opening", """
             If we say we have no sin, we deceive ourselves, and the truth is not in
            us. If we confess our sins, he is faithful and just to forgive us our sins
            and to cleanse us from all unrighteousness.
            """),
            dgettext("ep_opening", "1 John 1:8-9")
          },
          {dgettext("ep_opening", "For I know my transgressions, and my sin is ever before me."),
           dgettext("ep_opening", "Psalm 51:3")},
          {dgettext(
             "ep_opening",
             "To the Lord our God belong mercy and forgiveness, for we have rebelled against him."
           ), dgettext("ep_opening", "Daniel 9:9")}
        ],
        "goodFriday" => [
          {
            dgettext("ep_opening", """
              All we like sheep have gone astray; we have turned every one to his
            own way; and the Lord has laid on him the iniquity of us all.
            """),
            dgettext("ep_opening", "Isaiah 53:6")
          }
        ],
        "easter" => [
          {
            dgettext(
              "ep_opening",
              "Thanks be to God, who gives us the victory through our Lord Jesus Christ."
            ),
            dgettext("ep_opening", "1 Corinthians 15:57")
          },
          {
            dgettext("ep_opening", """
              If then you have been raised with Christ, seek the things that are
            above, where Christ is, seated at the right hand of God.
            """),
            dgettext("ep_opening", "Colossians 3:1")
          }
        ],
        "ascension" => [
          {
            dgettext("ep_opening", """
              For Christ has entered, not into holy places made with hands, which
            are copies of the true things, but into heaven itself, now to appear in
            the presence of God on our behalf.
            """),
            dgettext("ep_opening", "Hebrews 9:24")
          }
        ],
        "pentecost" => [
          {
            dgettext("ep_opening", """
              The Spirit and the Bride say, “Come.” And let the one who hears say,
            “Come.” And let the one who is thirsty come; let the one who desires
            take the water of life without price.
            """),
            dgettext("ep_opening", "Revelation 22:17")
          },
          {
            dgettext("ep_opening", """
              There is a river whose streams make glad the city of God, the holy
            habitation of the Most High.
            """),
            dgettext("ep_opening", "Psalm 46:4")
          }
        ],
        "trinity" => [
          {
            dgettext(
              "ep_opening",
              "Holy, holy, holy, is the Lord God of Hosts; the whole earth is full of his glory!"
            ),
            dgettext("ep_opening", "Isaiah 6:3")
          }
        ],
        "thanksgiving" => [
          {
            dgettext("ep_opening", """
            The Lord by wisdom founded the earth; by understanding he
            established the heavens; by his knowledge the deeps broke open, and
            the clouds drop down the dew.
            """),
            dgettext("ep_opening", "Proverbs 3:19-20")
          }
        ],
        "proper" => [
          {
            dgettext(
              "ep_opening",
              "The Lord is in his holy temple; let all the earth keep silence before him."
            ),
            dgettext("ep_opening", "Habakkuk 2:20")
          },
          {
            dgettext(
              "ep_opening",
              "O Lord, I love the habitation of your house and the place where your glory dwells."
            ),
            dgettext("ep_opening", "Psalm 26:8")
          },
          {
            dgettext("ep_opening", """
              Let my prayer be counted as incense before you, and the lifting up of
            my hands as the evening sacrifice!
            """),
            dgettext("ep_opening", "Psalm 141:2")
          },
          {
            dgettext(
              "ep_opening",
              "Worship the Lord in the splendor of holiness; tremble before him, all the earth!"
            ),
            dgettext("ep_opening", "Psalm 96:9")
          },
          {
            dgettext("ep_opening", """
              Let the words of my mouth and the meditation of my heart be
            acceptable in your sight, O Lord, my rock and my redeemer.
            """),
            dgettext("ep_opening", "Psalm 19:14")
          }
        ]
      },
      "January01" => %{
        title: "Holy Name",
        mp1: [%{style: "req", read: "Gen 1"}],
        mp2: [%{style: "req", read: "John 1:1-28"}],
        mpp: [{1, 1, 999}, {2, 1, 999}],
        ep1: [%{style: "req", read: "Gal 1"}],
        ep2: [%{style: "req", read: "Luke 2:8-21"}],
        epp: [{3, 1, 999}, {4, 1, 999}]
      },
      "January02" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 2"}],
        mp2: [%{style: "req", read: "John 1:29-end"}],
        mpp: [{5, 1, 999}, {6, 1, 999}],
        ep1: [%{style: "req", read: "Jer 1"}],
        ep2: [%{style: "req", read: "Gal 2"}],
        epp: [{7, 1, 999}]
      },
      "January03" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 3"}],
        mp2: [%{style: "req", read: "John 2"}],
        mpp: [{9, 1, 999}],
        ep1: [%{style: "req", read: "Jer 2"}],
        ep2: [%{style: "req", read: "Gal 3"}],
        epp: [{10, 1, 999}]
      },
      "January04" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 4 "}],
        mp2: [%{style: "req", read: "John 3:1-21"}],
        mpp: [{8, 1, 999}, {11, 1, 999}],
        ep1: [%{style: "req", read: "Jer 3"}],
        ep2: [%{style: "req", read: "Gal 4"}],
        epp: [{15, 1, 999}, {16, 1, 999}]
      },
      "January05" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 5"}],
        mp2: [%{style: "req", read: "John 3:22-end"}],
        mpp: [{12, 1, 999}, {13, 1, 999}, {14, 1, 999}],
        ep1: [%{style: "req", read: "Jer 4"}],
        ep2: [%{style: "req", read: "Gal 5"}],
        epp: [{17, 1, 999}]
      },
      "January06" => %{
        title: "Epiphany",
        mp1: [%{style: "req", read: "Gen 6"}],
        mp2: [%{style: "req", read: "Matt 2:1-12"}],
        mpp: [{96, 1, 999}, {97, 1, 999}],
        ep1: [%{style: "req", read: "Jer 5"}],
        ep2: [%{style: "req", read: "John 2:1-12"}],
        epp: [{67, 1, 999}, {72, 1, 999}]
      },
      "January07" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 7 "}],
        mp2: [%{style: "req", read: "John 4:1-26"}],
        mpp: [{18, 1, 20}],
        ep1: [%{style: "req", read: "Jer 6"}],
        ep2: [%{style: "req", read: "Gal 6"}],
        epp: [{18, 21, 50}]
      },
      "January08" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 8 "}],
        mp2: [%{style: "req", read: "John 4:27-end"}],
        mpp: [{20, 1, 999}, {21, 1, 999}],
        ep1: [%{style: "req", read: "Jer 7"}],
        ep2: [%{style: "req", read: "1 Thess 1"}],
        epp: [{22, 1, 999}]
      },
      "January09" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 9"}],
        mp2: [%{style: "req", read: "John 5:1-24"}],
        mpp: [{19, 1, 999}, {23, 1, 999}],
        ep1: [%{style: "req", read: "Jer 8"}],
        ep2: [%{style: "req", read: "1 Thess 2:1-16"}],
        epp: [{25, 1, 999}]
      },
      "January10" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 10"}],
        mp2: [%{style: "req", read: "John 5:25-end"}],
        mpp: [{24, 1, 999}, {26, 1, 999}],
        ep1: [%{style: "req", read: "Jer 9"}],
        ep2: [%{style: "req", read: "1 Thess 2:17-999, 3-end"}],
        epp: [{27, 1, 999}]
      },
      "January11" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 11"}],
        mp2: [%{style: "req", read: "John 6:1-21"}],
        mpp: [{28, 1, 999}, {29, 1, 999}],
        ep1: [%{style: "req", read: "Jer 10"}],
        ep2: [%{style: "req", read: "1 Thess 4:1-12"}],
        epp: [{31, 1, 999}]
      },
      "January12" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 12"}],
        mp2: [%{style: "req", read: "John 6:22-40"}],
        mpp: [{30, 1, 999}, {32, 1, 999}],
        ep1: [%{style: "req", read: "Jer 11"}],
        ep2: [%{style: "req", read: "1 Thess 4:13-end, 5:1-11"}],
        epp: [{33, 1, 999}]
      },
      "January13" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 13"}],
        mp2: [%{style: "req", read: "John 6:41-end"}],
        mpp: [{34, 1, 999}],
        ep1: [%{style: "req", read: "Jer 12"}],
        ep2: [%{style: "req", read: "1 Thess 5:12-end"}],
        epp: [{35, 1, 999}]
      },
      "January14" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 14"}],
        mp2: [%{style: "req", read: "John 7:1-24"}],
        mpp: [{36, 1, 999}],
        ep1: [%{style: "req", read: "Jer 13"}],
        ep2: [%{style: "req", read: "2 Thess 1"}],
        epp: [{38, 1, 999}]
      },
      "January15" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 15 "}],
        mp2: [%{style: "req", read: "John 7:25-52"}],
        mpp: [{37, 1, 18}],
        ep1: [%{style: "req", read: "Jer 14"}],
        ep2: [%{style: "req", read: "2 Thess 2"}],
        epp: [{37, 19, 42}]
      },
      "January16" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 16 "}],
        mp2: [%{style: "req", read: "John 7:53-end, 8:1-30"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "Jer 15"}],
        ep2: [%{style: "req", read: "2 Thess 3"}],
        epp: [{39, 1, 999}, {41, 1, 999}]
      },
      "January17" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 17"}],
        mp2: [%{style: "req", read: "John 8:31-end"}],
        mpp: [{42, 1, 999}, {43, 1, 999}],
        ep1: [%{style: "req", read: "Jer 16"}],
        ep2: [%{style: "req", read: "1 Cor 1:1-25"}],
        epp: [{44, 1, 999}]
      },
      "January18" => %{
        title: "Confession Of St. Peter",
        mp1: [%{style: "req", read: "Gen 18"}],
        mp2: [%{style: "req", read: "Matt 16:13-20"}],
        mpp: [{45, 1, 999}],
        ep1: [%{style: "req", read: "1 Cor 1:26-999, 2:1-end"}],
        ep2: [%{style: "req", read: "},"}],
        epp: [{46, 1, 999}]
      },
      "January19" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 19"}],
        mp2: [%{style: "req", read: "John 9"}],
        mpp: [{47, 1, 999}, {48, 1, 999}],
        ep1: [%{style: "req", read: "Jer 18"}],
        ep2: [%{style: "req", read: "1 Cor 3"}],
        epp: [{49, 1, 999}]
      },
      "January20" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 20"}],
        mp2: [%{style: "req", read: "John 10:1-21"}],
        mpp: [{50, 1, 999}],
        ep1: [%{style: "req", read: "Jer 19"}],
        ep2: [%{style: "req", read: "1 Cor 4:1-17"}],
        epp: [{51, 1, 999}]
      },
      "January21" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 21"}],
        mp2: [%{style: "req", read: "John 10:22-end"}],
        mpp: [{52, 1, 999}, {53, 1, 999}, {54, 1, 999}],
        ep1: [%{style: "req", read: "Jer 20"}],
        ep2: [%{style: "req", read: "1 Cor 4:18-end, 5:1-end"}],
        epp: [{55, 1, 999}]
      },
      "January22" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 22"}],
        mp2: [%{style: "req", read: "John 11:1-44"}],
        mpp: [{56, 1, 999}, {57, 1, 999}],
        ep1: [%{style: "req", read: "Jer 21"}],
        ep2: [%{style: "req", read: "1 Cor 6"}],
        epp: [{58, 1, 999}, {60, 1, 999}]
      },
      "January23" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 23"}],
        mp2: [%{style: "req", read: "John 11:45-end"}],
        mpp: [{59, 1, 999}],
        ep1: [%{style: "req", read: "Jer 22"}],
        ep2: [%{style: "req", read: "1 Cor 7"}],
        epp: [{63, 1, 999}, {64, 1, 999}]
      },
      "January24" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 24"}],
        mp2: [%{style: "req", read: "John 12:1-19"}],
        mpp: [{61, 1, 999}, {62, 1, 999}],
        ep1: [%{style: "req", read: "Jer 23"}],
        ep2: [%{style: "req", read: "1 Cor 8"}],
        epp: [{65, 1, 999}, {67, 1, 999}]
      },
      "January25" => %{
        title: "Conversion Of St. Paul",
        mp1: [%{style: "req", read: "Acts 9:1-22"}],
        mp2: [%{style: "req", read: "John 12:20-end"}],
        mpp: [{68, 1, 18}],
        ep1: [%{style: "req", read: "Jer 24"}],
        ep2: [%{style: "req", read: "1 Cor 9"}],
        epp: [{68, 19, 36}]
      },
      "January26" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 25"}],
        mp2: [%{style: "req", read: "John 13"}],
        mpp: [{69, 1, 19}],
        ep1: [%{style: "req", read: "Jer 25"}],
        ep2: [%{style: "req", read: "1 Cor 10"}],
        epp: [{69, 20, 38}]
      },
      "January27" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 26"}],
        mp2: [%{style: "req", read: "John 14:1-14"}],
        mpp: [{66, 1, 999}],
        ep1: [%{style: "req", read: "Jer 26"}],
        ep2: [%{style: "req", read: "1 Cor 11"}],
        epp: [{70, 1, 999}, {72, 1, 999}]
      },
      "January28" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 27"}],
        mp2: [%{style: "req", read: "John 14:15-end"}],
        mpp: [{71, 1, 999}],
        ep1: [%{style: "req", read: "Jer 27"}],
        ep2: [%{style: "req", read: "1 Cor 12"}],
        epp: [{73, 1, 999}]
      },
      "January29" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 28"}],
        mp2: [%{style: "req", read: "John 15:1-17"}],
        mpp: [{74, 1, 999}],
        ep1: [%{style: "req", read: "Jer 28"}],
        ep2: [%{style: "req", read: "1 Cor 13"}],
        epp: [{75, 1, 999}, {76, 1, 999}]
      },
      "January30" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 29"}],
        mp2: [%{style: "req", read: "John 15:18-end"}],
        mpp: [{77, 1, 999}],
        ep1: [%{style: "req", read: "Jer 29"}],
        ep2: [%{style: "req", read: "1 Cor 14:1-19"}],
        epp: [{79, 1, 999}, {82, 1, 999}]
      },
      "January31" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 30"}],
        mp2: [%{style: "req", read: "John 16:1-15"}],
        mpp: [{78, 1, 17}],
        ep1: [%{style: "req", read: "Jer 30"}],
        ep2: [%{style: "req", read: "1 Cor 14:20-end"}],
        epp: [{78, 18, 39}]
      },
      "February01" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 31"}],
        mp2: [%{style: "req", read: "John 16:16-end"}],
        mpp: [{78, 41, 73}],
        ep1: [%{style: "req", read: "Jer 31"}],
        ep2: [%{style: "req", read: "1 Cor 15:1-34"}],
        epp: [{80, 1, 999}]
      },
      "February02" => %{
        title: "Presentation",
        mp1: [%{style: "req", read: "Gen 32"}],
        mp2: [%{style: "req", read: "Luke 2:22-40"}],
        mpp: [{24, 1, 999}, {81, 1, 999}],
        ep1: [%{style: "req", read: "Jer 32"}],
        ep2: [%{style: "req", read: "1 Cor 15:35-end"}],
        epp: [{84, 1, 999}]
      },
      "February03" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 33"}],
        mp2: [%{style: "req", read: "John 17"}],
        mpp: [{83, 1, 999}],
        ep1: [%{style: "req", read: "Jer 33"}],
        ep2: [%{style: "req", read: "1 Cor 16"}],
        epp: [{85, 1, 999}]
      },
      "February04" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 34"}],
        mp2: [%{style: "req", read: "John 18:1-27"}],
        mpp: [{86, 1, 999}, {87, 1, 999}],
        ep1: [%{style: "req", read: "Jer 34"}],
        ep2: [%{style: "req", read: "2 Cor 1:1-end, 2:1-11"}],
        epp: [{88, 1, 999}]
      },
      "February05" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 35"}],
        mp2: [%{style: "req", read: "John 18:28-end"}],
        mpp: [{89, 1, 18}],
        ep1: [%{style: "req", read: "Jer 35"}],
        ep2: [%{style: "req", read: "2 Cor 2:12-end, 3:1-end"}],
        epp: [{89, 19, 52}]
      },
      "February06" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 36"}],
        mp2: [%{style: "req", read: "John 19:1-37"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Jer 36"}],
        ep2: [%{style: "req", read: "2 Cor 4"}],
        epp: [{91, 1, 999}]
      },
      "February07" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 37"}],
        mp2: [%{style: "req", read: "John 19:38-end"}],
        mpp: [{92, 1, 999}, {93, 1, 999}],
        ep1: [%{style: "req", read: "Jer 37"}],
        ep2: [%{style: "req", read: "2 Cor 5"}],
        epp: [{94, 1, 999}]
      },
      "February08" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 38"}],
        mp2: [%{style: "req", read: "John 20"}],
        mpp: [{95, 1, 999}, {96, 1, 999}],
        ep1: [%{style: "req", read: "Jer 38"}],
        ep2: [%{style: "req", read: "2 Cor 6"}],
        epp: [{97, 1, 999}, {98, 1, 999}]
      },
      "February09" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 39"}],
        mp2: [%{style: "req", read: "John 21"}],
        mpp: [{99, 1, 999}, {100, 1, 999}, {101, 1, 999}],
        ep1: [%{style: "req", read: "Jer 39"}],
        ep2: [%{style: "req", read: "2 Cor 7"}],
        epp: [{102, 1, 999}]
      },
      "February10" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 40"}],
        mp2: [%{style: "req", read: "Matt 1:1-17"}],
        mpp: [{103, 1, 999}],
        ep1: [%{style: "req", read: "Jer 40"}],
        ep2: [%{style: "req", read: "2 Cor 8"}],
        epp: [{104, 1, 999}]
      },
      "February11" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 41"}],
        mp2: [%{style: "req", read: "Matt 1:18-end"}],
        mpp: [{105, 1, 22}],
        ep1: [%{style: "req", read: "Jer 41"}],
        ep2: [%{style: "req", read: "2 Cor 9"}],
        epp: [{105, 23, 45}]
      },
      "February12" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 42"}],
        mp2: [%{style: "req", read: "Matt 2:1-18"}],
        mpp: [{106, 1, 18}],
        ep1: [%{style: "req", read: "Jer 42"}],
        ep2: [%{style: "req", read: "2 Cor 10"}],
        epp: [{106, 19, 48}]
      },
      "February13" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 43"}],
        mp2: [%{style: "req", read: "Matt 2:19-end"}],
        mpp: [{107, 1, 22}],
        ep1: [%{style: "req", read: "Jer 43"}],
        ep2: [%{style: "req", read: "2 Cor 11"}],
        epp: [{107, 23, 43}]
      },
      "February14" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 44"}],
        mp2: [%{style: "req", read: "Matt 3"}],
        mpp: [{108, 1, 999}, {110, 1, 999}],
        ep1: [%{style: "req", read: "Jer 44"}],
        ep2: [%{style: "req", read: "2 Cor 12:1-13"}],
        epp: [{109, 1, 999}]
      },
      "February15" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 45"}],
        mp2: [%{style: "req", read: "Matt 4"}],
        mpp: [{111, 1, 999}, {112, 1, 999}],
        ep1: [%{style: "req", read: "Jer 45"}],
        ep2: [%{style: "req", read: "2 Cor 12:14-999, 13-end"}],
        epp: [{113, 1, 999}, {114, 1, 999}]
      },
      "February16" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 46"}],
        mp2: [%{style: "req", read: "Matt 5"}],
        mpp: [{115, 1, 999}],
        ep1: [%{style: "req", read: "Jer 46"}],
        ep2: [%{style: "req", read: "Rom 1"}],
        epp: [{116, 1, 999}, {117, 1, 999}]
      },
      "February17" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 47"}],
        mp2: [%{style: "req", read: "Matt 6:1-18"}],
        mpp: [{119, 1, 24}],
        ep1: [%{style: "req", read: "Jer 47"}],
        ep2: [%{style: "req", read: "Rom 2"}],
        epp: [{119, 25, 48}]
      },
      "February18" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 48"}],
        mp2: [%{style: "req", read: "Matt 6:19-end"}],
        mpp: [{119, 49, 72}],
        ep1: [%{style: "req", read: "Jer 48"}],
        ep2: [%{style: "req", read: "Rom 3"}],
        epp: [{119, 73, 88}]
      },
      "February19" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 49"}],
        mp2: [%{style: "req", read: "Matt 7"}],
        mpp: [{119, 89, 104}],
        ep1: [%{style: "req", read: "Jer 49"}],
        ep2: [%{style: "req", read: "Rom 4"}],
        epp: [{119, 105, 128}]
      },
      "February20" => %{
        title: "",
        mp1: [%{style: "req", read: "Gen 50"}],
        mp2: [%{style: "req", read: "Matt 8:1-17"}],
        mpp: [{119, 129, 152}],
        ep1: [%{style: "req", read: "Jer 50"}],
        ep2: [%{style: "req", read: "Rom 5"}],
        epp: [{119, 153, 176}]
      },
      "February21" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 1"}],
        mp2: [%{style: "req", read: "Matt 8:18-end"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Jer 51"}],
        ep2: [%{style: "req", read: "Rom 6"}],
        epp: [{120, 1, 999}, {121, 1, 999}]
      },
      "February22" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 2"}],
        mp2: [%{style: "req", read: "Matt 9:1-17"}],
        mpp: [{122, 1, 999}, {123, 1, 999}],
        ep1: [%{style: "req", read: "Jer 52"}],
        ep2: [%{style: "req", read: "Rom 7"}],
        epp: [{124, 1, 999}, {125, 1, 999}, {126, 1, 999}]
      },
      "February23" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 3"}],
        mp2: [%{style: "req", read: "Matt 9:18-34"}],
        mpp: [{127, 1, 999}, {128, 1, 999}],
        ep1: [%{style: "req", read: "Baruch 4"}],
        ep2: [%{style: "req", read: "Rom 8:1-17"}],
        epp: [{129, 1, 999}, {130, 1, 999}, {131, 1, 999}]
      },
      "February24" => %{
        title: "Matthias",
        mp1: [%{style: "req", read: "Acts 1:15-26"}],
        mp2: [%{style: "req", read: "Matt 9:35-end, 10:1-23"}],
        mpp: [{132, 1, 999}, {133, 1, 999}],
        ep1: [%{style: "req", read: "Baruch 5"}],
        ep2: [%{style: "req", read: "Rom 8:18-end"}],
        epp: [{134, 1, 999}, {135, 1, 999}]
      },
      "February25" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 4"}],
        mp2: [%{style: "req", read: "Matt 10:24-end"}],
        mpp: [{136, 1, 999}],
        ep1: [%{style: "req", read: "Lam 1"}],
        ep2: [%{style: "req", read: "Rom 9"}],
        epp: [{137, 1, 999}, {138, 1, 999}]
      },
      "February26" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 5"}],
        mp2: [%{style: "req", read: "Matt 11"}],
        mpp: [{139, 1, 999}],
        ep1: [%{style: "req", read: "Lam 2"}],
        ep2: [%{style: "req", read: "Rom 10"}],
        epp: [{141, 1, 999}, {142, 1, 999}]
      },
      "February27" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 6"}],
        mp2: [%{style: "req", read: "Matt 12:1-21"}],
        mpp: [{140, 1, 999}],
        ep1: [%{style: "req", read: "Lam 3"}],
        ep2: [%{style: "req", read: "Rom 11"}],
        epp: [{143, 1, 999}]
      },
      "February28" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 7"}],
        mp2: [%{style: "req", read: "Matt 12:22-end"}],
        mpp: [{144, 1, 999}],
        ep1: [%{style: "req", read: "Lam 4"}],
        ep2: [%{style: "req", read: "Rom 12"}],
        epp: [{145, 1, 999}]
      },
      "ashWednesday" => %{
        title: "Ash Wednesday",
        mp1: [%{style: "req", read: "Isa 58:1-12"}],
        mp2: [%{style: "req", read: "Luke 18:9-14"}],
        mpp: [{38, 1, 999}],
        ep1: [%{style: "req", read: "Jonah 3:6-10"}],
        ep2: [%{style: "req", read: "1 Cor 9:24-27"}],
        epp: [{6, 1, 999}, {32, 1, 999}]
      },
      "February29" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 2"}],
        mp2: [%{style: "req", read: "Luke 24:44-53"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Joel 2"}],
        ep2: [%{style: "req", read: "2 Pet 3"}],
        epp: [{104, 1, 999}]
      },
      "March01" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 8"}],
        mp2: [%{style: "req", read: "Matt 13:1-23"}],
        mpp: [{146, 1, 999}],
        ep1: [%{style: "req", read: "Lam 5"}],
        ep2: [%{style: "req", read: "Rom 13"}],
        epp: [{147, 1, 999}]
      },
      "March02" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 9"}],
        mp2: [%{style: "req", read: "Matt 13:24-43"}],
        mpp: [{148, 1, 999}],
        ep1: [%{style: "req", read: "Prov 1"}],
        ep2: [%{style: "req", read: "Rom 14"}],
        epp: [{149, 1, 999}, {150, 1, 999}]
      },
      "March03" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 10"}],
        mp2: [%{style: "req", read: "Matt 13:44-end"}],
        mpp: [{1, 1, 999}, {2, 1, 999}],
        ep1: [%{style: "req", read: "Prov 2"}],
        ep2: [%{style: "req", read: "Rom 15"}],
        epp: [{3, 1, 999}, {4, 1, 999}]
      },
      "March04" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 11"}],
        mp2: [%{style: "req", read: "Matt 14"}],
        mpp: [{5, 1, 999}, {6, 1, 999}],
        ep1: [%{style: "req", read: "Prov 3"}],
        ep2: [%{style: "req", read: "Rom 16"}],
        epp: [{7, 1, 999}]
      },
      "March05" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 12"}],
        mp2: [%{style: "req", read: "Matt 15:1-28"}],
        mpp: [{9, 1, 999}],
        ep1: [%{style: "req", read: "Prov 4"}],
        ep2: [%{style: "req", read: "Phil 1:1-11"}],
        epp: [{10, 1, 999}]
      },
      "March06" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 13"}],
        mp2: [%{style: "req", read: "Matt 15:29-end, 16:1-12"}],
        mpp: [{8, 1, 999}, {11, 1, 999}],
        ep1: [%{style: "req", read: "Prov 5"}],
        ep2: [%{style: "req", read: "Phil 1:12-end"}],
        epp: [{15, 1, 999}, {16, 1, 999}]
      },
      "March07" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 14"}],
        mp2: [%{style: "req", read: "Matt 16:13-end"}],
        mpp: [{12, 1, 999}, {13, 1, 999}, {14, 1, 999}],
        ep1: [%{style: "req", read: "Prov 6"}],
        ep2: [%{style: "req", read: "Phil 2:1-11"}],
        epp: [{17, 1, 999}]
      },
      "March08" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 15"}],
        mp2: [%{style: "req", read: "Matt 17:1-23"}],
        mpp: [{18, 1, 20}],
        ep1: [%{style: "req", read: "Prov 7"}],
        ep2: [%{style: "req", read: "Phil 2:12-end"}],
        epp: [{18, 21, 50}]
      },
      "March09" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 16"}],
        mp2: [%{style: "req", read: "Matt 17:24-end, 18:1-14"}],
        mpp: [{20, 1, 999}, {21, 1, 999}],
        ep1: [%{style: "req", read: "Prov 8"}],
        ep2: [%{style: "req", read: "Phil 3"}],
        epp: [{22, 1, 999}]
      },
      "March10" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 17"}],
        mp2: [%{style: "req", read: "Matt 18:15-end"}],
        mpp: [{19, 1, 999}, {23, 1, 999}],
        ep1: [%{style: "req", read: "Prov 9"}],
        ep2: [%{style: "req", read: "Phil 4"}],
        epp: [{25, 1, 999}]
      },
      "March11" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 18"}],
        mp2: [%{style: "req", read: "Matt 19:1-15"}],
        mpp: [{24, 1, 999}, {26, 1, 999}],
        ep1: [%{style: "req", read: "Prov 10"}],
        ep2: [%{style: "req", read: "Col 1:1-20"}],
        epp: [{27, 1, 999}]
      },
      "March12" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 19"}],
        mp2: [%{style: "req", read: "Matt 19:16-20:16"}],
        mpp: [{28, 1, 999}, {29, 1, 999}],
        ep1: [%{style: "req", read: "Prov 11"}],
        ep2: [%{style: "req", read: "Col 1:21-end, 2:1-7"}],
        epp: [{31, 1, 999}]
      },
      "March13" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 20"}],
        mp2: [%{style: "req", read: "Matt 20:17-end"}],
        mpp: [{30, 1, 999}, {32, 1, 999}],
        ep1: [%{style: "req", read: "Prov 12"}],
        ep2: [%{style: "req", read: "Col 2:8-19"}],
        epp: [{33, 1, 999}]
      },
      "March14" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 21"}],
        mp2: [%{style: "req", read: "Matt 21:1-22"}],
        mpp: [{34, 1, 999}],
        ep1: [%{style: "req", read: "Prov 13"}],
        ep2: [%{style: "req", read: "Col 2:20-end, 3:1-11"}],
        epp: [{35, 1, 999}]
      },
      "March15" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 22"}],
        mp2: [%{style: "req", read: "Matt 21:23-end"}],
        mpp: [{36, 1, 999}],
        ep1: [%{style: "req", read: "Prov 14"}],
        ep2: [%{style: "req", read: "Col 3:12-end"}],
        epp: [{38, 1, 999}]
      },
      "March16" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 23"}],
        mp2: [%{style: "req", read: "Matt 22:1-33"}],
        mpp: [{37, 1, 18}],
        ep1: [%{style: "req", read: "Prov 15"}],
        ep2: [%{style: "req", read: "Col 4"}],
        epp: [{37, 19, 42}]
      },
      "March17" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 24"}],
        mp2: [%{style: "req", read: "Matt 22:34-23:12"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "Prov 16"}],
        ep2: [%{style: "req", read: "Philemon"}],
        epp: [{39, 1, 999}, {41, 1, 999}]
      },
      "March18" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 25"}],
        mp2: [%{style: "req", read: "Matt 23:13-end"}],
        mpp: [{42, 1, 999}, {43, 1, 999}],
        ep1: [%{style: "req", read: "Prov 17"}],
        ep2: [%{style: "req", read: "Eph 1:1-14"}],
        epp: [{44, 1, 999}]
      },
      "March19" => %{
        title: "St. Joseph",
        mp1: [%{style: "req", read: "Exod 26"}],
        mp2: [%{style: "req", read: "Matt 24:1-28"}],
        mpp: [{45, 1, 999}],
        ep1: [%{style: "req", read: "Eph 1:15-end"}],
        ep2: [%{style: "req", read: "Matt 1:18-26"}],
        epp: [{46, 1, 999}]
      },
      "March20" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 27"}],
        mp2: [%{style: "req", read: "Matt 24:29-end"}],
        mpp: [{47, 1, 999}, {48, 1, 999}],
        ep1: [%{style: "req", read: "Prov 18"}],
        ep2: [%{style: "req", read: "Eph 2:1-10"}],
        epp: [{49, 1, 999}]
      },
      "March21" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 28"}],
        mp2: [%{style: "req", read: "Matt 25:1-30"}],
        mpp: [{50, 1, 999}],
        ep1: [%{style: "req", read: "Prov 19"}],
        ep2: [%{style: "req", read: "Eph 2:11-end"}],
        epp: [{51, 1, 999}]
      },
      "March22" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 29"}],
        mp2: [%{style: "req", read: "Matt 25:31-end"}],
        mpp: [{52, 1, 999}, {53, 1, 999}, {54, 1, 999}],
        ep1: [%{style: "req", read: "Prov 20"}],
        ep2: [%{style: "req", read: "Eph 3"}],
        epp: [{55, 1, 999}]
      },
      "March23" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 30"}],
        mp2: [%{style: "req", read: "Matt 26:1-30"}],
        mpp: [{56, 1, 999}, {57, 1, 999}],
        ep1: [%{style: "req", read: "Prov 21"}],
        ep2: [%{style: "req", read: "Eph 4:1-16"}],
        epp: [{58, 1, 999}, {60, 1, 999}]
      },
      "March24" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 31"}],
        mp2: [%{style: "req", read: "Matt 26:31-56"}],
        mpp: [{59, 1, 999}],
        ep1: [%{style: "req", read: "Prov 22"}],
        ep2: [%{style: "req", read: "Eph 4:17-end"}],
        epp: [{63, 1, 999}, {64, 1, 999}]
      },
      "March25" => %{
        title: "Annunciation",
        mp1: [%{style: "req", read: "Exod 32"}],
        mp2: [%{style: "req", read: "Luke 1:26-38"}],
        mpp: [{113, 1, 999}, {138, 1, 999}],
        ep1: [%{style: "req", read: "Prov 23"}],
        ep2: [%{style: "req", read: "Eph 5:1-21"}],
        epp: [{131, 1, 999}, {132, 1, 999}]
      },
      "March26" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 33"}],
        mp2: [%{style: "req", read: "Matt 26:57-end"}],
        mpp: [{61, 1, 999}, {62, 1, 999}],
        ep1: [%{style: "req", read: "Prov 24"}],
        ep2: [%{style: "req", read: "Eph 5:22-end"}],
        epp: [{65, 1, 999}, {67, 1, 999}]
      },
      "March27" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 34"}],
        mp2: [%{style: "req", read: "Matt 27:1-26"}],
        mpp: [{68, 1, 18}],
        ep1: [%{style: "req", read: "Prov 25"}],
        ep2: [%{style: "req", read: "Eph 6:1-9"}],
        epp: [{68, 19, 36}]
      },
      "March28" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 35"}],
        mp2: [%{style: "req", read: "Matt 27:27-56"}],
        mpp: [{69, 1, 19}],
        ep1: [%{style: "req", read: "Prov 26"}],
        ep2: [%{style: "req", read: "Eph 6:10-end"}],
        epp: [{69, 20, 38}]
      },
      "March29" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 36"}],
        mp2: [%{style: "req", read: "Matt 27:57-999,28-end"}],
        mpp: [{66, 1, 999}],
        ep1: [%{style: "req", read: "Prov 27"}],
        ep2: [%{style: "req", read: "1 Tim 1:1-17"}],
        epp: [{70, 1, 999}, {72, 1, 999}]
      },
      "March30" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 37"}],
        mp2: [%{style: "req", read: "Mark 1:1-13"}],
        mpp: [{71, 1, 999}],
        ep1: [%{style: "req", read: "Prov 28"}],
        ep2: [%{style: "req", read: "1 Tim 1:18-2 end"}],
        epp: [{73, 1, 999}]
      },
      "March31" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 38"}],
        mp2: [%{style: "req", read: "Mark 1:14-31"}],
        mpp: [{74, 1, 999}],
        ep1: [%{style: "req", read: "Prov 29"}],
        ep2: [%{style: "req", read: "1 Tim 3"}],
        epp: [{75, 1, 999}, {76, 1, 999}]
      },
      "maundyThursday" => %{
        title: "Maundy Thursday",
        mp1: [%{style: "req", read: "Dan 9"}],
        mp2: [%{style: "req", read: "John 13:1-20"}],
        mpp: [{41, 1, 999}],
        ep1: [%{style: "req", read: "Cor 10:1-22"}],
        ep2: [%{style: "req", read: "John 13:21-38"}],
        epp: [{142, 1, 999}, {143, 1, 999}]
      },
      "goodFriday" => %{
        title: "Good Friday",
        mp1: [%{style: "req", read: "Lam 3:1-36"}],
        mp2: [%{style: "req", read: "John 18"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "1 Pet 2:11-25"}],
        ep2: [%{style: "req", read: "Luke 23:18-49"}],
        epp: [{102, 1, 999}]
      },
      "holySaturday" => %{
        title: "Holy Saturday",
        mp1: [%{style: "req", read: "Lam 3:37-58"}],
        mp2: [%{style: "req", read: "Heb 4"}],
        mpp: [{88, 1, 999}],
        ep1: [%{style: "req", read: "1 Pet 4:1-8"}],
        ep2: [%{style: "req", read: "Luke 23:50-56"}],
        epp: [{91, 1, 999}]
      },
      "easterDay" => %{
        title: "Easter Day",
        mp1: [%{style: "req", read: "Exod 15"}],
        mp2: [%{style: "req", read: "Acts 2:22-32"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Rom 6"}],
        ep2: [%{style: "req", read: "Luke 24:13-43"}],
        epp: [{111, 1, 999}, {113, 1, 999}, {114, 1, 999}]
      },
      "ascension" => %{
        title: "Ascension",
        mp1: [%{style: "req", read: "2 Kings 2"}],
        mp2: [%{style: "req", read: "Eph 4:1-17"}],
        mpp: [{8, 1, 999}, {47, 1, 999}],
        ep1: [%{style: "req", read: "Heb 8"}],
        ep2: [%{style: "req", read: "Luke 24:44-53"}],
        epp: [{21, 1, 999}, {24, 1, 999}]
      },
      "pentecost" => %{
        title: "Pentecost",
        mp1: [%{style: "req", read: "Isa 11"}],
        mp2: [%{style: "req", read: "John 16:1-15"}],
        mpp: [{48, 1, 999}],
        ep1: [%{style: "req", read: "Acts 2"}],
        ep2: [%{style: "req", read: "Acts 10:34-end"}],
        epp: [{145, 1, 999}]
      },
      "April01" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 39"}],
        mp2: [%{style: "req", read: "Mark 1:32-end"}],
        mpp: [{77, 1, 999}],
        ep1: [%{style: "req", read: "Prov 30"}],
        ep2: [%{style: "req", read: "1 Tim 4"}],
        epp: [{79, 1, 999}, {82, 1, 999}]
      },
      "April02" => %{
        title: "",
        mp1: [%{style: "req", read: "Exod 40"}],
        mp2: [%{style: "req", read: "Mark 2:1-22"}],
        mpp: [{78, 1, 17}],
        ep1: [%{style: "req", read: "Prov 31"}],
        ep2: [%{style: "req", read: "1 Tim 5"}],
        epp: [{78, 18, 39}]
      },
      "April03" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 1"}],
        mp2: [%{style: "req", read: "Mark 2:23-end, 3:1-12"}],
        mpp: [{78, 41, 73}],
        ep1: [%{style: "req", read: "Job 1"}],
        ep2: [%{style: "req", read: "1 Tim 6"}],
        epp: [{80, 1, 999}]
      },
      "April04" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 8"}],
        mp2: [%{style: "req", read: "Mark 3:13-end"}],
        mpp: [{81, 1, 999}],
        ep1: [%{style: "req", read: "Job 2"}],
        ep2: [%{style: "req", read: "Titus 1"}],
        epp: [{83, 1, 999}]
      },
      "April05" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 10"}],
        mp2: [%{style: "req", read: "Mark 4:1-34"}],
        mpp: [{84, 1, 999}],
        ep1: [%{style: "req", read: "Job 3"}],
        ep2: [%{style: "req", read: "Titus 2"}],
        epp: [{85, 1, 999}]
      },
      "April06" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 16"}],
        mp2: [%{style: "req", read: "Mark 4:35-end, 5:1-20"}],
        mpp: [{86, 1, 999}, {87, 1, 999}],
        ep1: [%{style: "req", read: "Job 4"}],
        ep2: [%{style: "req", read: "Titus 3"}],
        epp: [{88, 1, 999}]
      },
      "April07" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 17"}],
        mp2: [%{style: "req", read: "Mark 5:21-end"}],
        mpp: [{89, 1, 18}],
        ep1: [%{style: "req", read: "Job 5"}],
        ep2: [%{style: "req", read: "2 Tim 1"}],
        epp: [{89, 19, 52}]
      },
      "April08" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 18"}],
        mp2: [%{style: "req", read: "Mark 6:1-29"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Job 6"}],
        ep2: [%{style: "req", read: "2 Tim 2"}],
        epp: [{91, 1, 999}]
      },
      "April09" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 19"}],
        mp2: [%{style: "req", read: "Mark 6:30-end"}],
        mpp: [{92, 1, 999}, {93, 1, 999}],
        ep1: [%{style: "req", read: "Job 7"}],
        ep2: [%{style: "req", read: "2 Tim 3"}],
        epp: [{94, 1, 999}]
      },
      "April10" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 20"}],
        mp2: [%{style: "req", read: "Mark 7:1-23"}],
        mpp: [{95, 1, 999}, {96, 1, 999}],
        ep1: [%{style: "req", read: "Job 8"}],
        ep2: [%{style: "req", read: "2 Tim 4"}],
        epp: [{97, 1, 999}, {98, 1, 999}]
      },
      "April11" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 23"}],
        mp2: [%{style: "req", read: "Mark 7:24-end, 8:1-10"}],
        mpp: [{99, 1, 999}, {100, 1, 999}, {101, 1, 999}],
        ep1: [%{style: "req", read: "Job 9"}],
        ep2: [%{style: "req", read: "Heb 1"}],
        epp: [{102, 1, 999}]
      },
      "April12" => %{
        title: "",
        mp1: [%{style: "req", read: "Lev 26"}],
        mp2: [%{style: "req", read: "Mark 8:11-end"}],
        mpp: [{103, 1, 999}],
        ep1: [%{style: "req", read: "Job 10"}],
        ep2: [%{style: "req", read: "Heb 2"}],
        epp: [{104, 1, 999}]
      },
      "April13" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 6"}],
        mp2: [%{style: "req", read: "Mark 9:1-29"}],
        mpp: [{105, 1, 22}],
        ep1: [%{style: "req", read: "Job 11"}],
        ep2: [%{style: "req", read: "Heb 3"}],
        epp: [{105, 23, 45}]
      },
      "April14" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 8"}],
        mp2: [%{style: "req", read: "Mark 9:30-end"}],
        mpp: [{106, 1, 18}],
        ep1: [%{style: "req", read: "Job 12"}],
        ep2: [%{style: "req", read: "Heb 4:1-13"}],
        epp: [{106, 19, 48}]
      },
      "April15" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 11"}],
        mp2: [%{style: "req", read: "Mark 10:1-31"}],
        mpp: [{107, 1, 22}],
        ep1: [%{style: "req", read: "Job 13"}],
        ep2: [%{style: "req", read: "Heb 4:14-end, 5:1-10"}],
        epp: [{107, 23, 43}]
      },
      "April16" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 12"}],
        mp2: [%{style: "req", read: "Mark 10:32-end"}],
        mpp: [{108, 1, 999}, {110, 1, 999}],
        ep1: [%{style: "req", read: "Job 14"}],
        ep2: [%{style: "req", read: "Heb 5:11-end, 6:1-end"}],
        epp: [{109, 1, 999}]
      },
      "April17" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 13"}],
        mp2: [%{style: "req", read: "Mark 11:1-26"}],
        mpp: [{111, 1, 999}, {112, 1, 999}],
        ep1: [%{style: "req", read: "Job 15"}],
        ep2: [%{style: "req", read: "Heb 7"}],
        epp: [{113, 1, 999}, {114, 1, 999}]
      },
      "April18" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 14"}],
        mp2: [%{style: "req", read: "Mark 11:27-end, 12:1-12"}],
        mpp: [{115, 1, 999}],
        ep1: [%{style: "req", read: "Job 16"}],
        ep2: [%{style: "req", read: "Heb 8"}],
        epp: [{116, 1, 999}, {117, 1, 999}]
      },
      "April19" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 15"}],
        mp2: [%{style: "req", read: "Mark 12:13-34"}],
        mpp: [{119, 1, 24}],
        ep1: [%{style: "req", read: "Job 17"}],
        ep2: [%{style: "req", read: "Heb 9:1-14"}],
        epp: [{119, 25, 48}]
      },
      "April20" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 16"}],
        mp2: [%{style: "req", read: "Mark 12:35-end, 13:1-13"}],
        mpp: [{119, 49, 72}],
        ep1: [%{style: "req", read: "Job 18"}],
        ep2: [%{style: "req", read: "Heb 9:15-end"}],
        epp: [{119, 73, 88}]
      },
      "April21" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 17"}],
        mp2: [%{style: "req", read: "Mark 13:14-end"}],
        mpp: [{119, 89, 104}],
        ep1: [%{style: "req", read: "Job 19"}],
        ep2: [%{style: "req", read: "Heb 10:1-18"}],
        epp: [{119, 105, 128}]
      },
      "April22" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 18"}],
        mp2: [%{style: "req", read: "Mark 14:1-25"}],
        mpp: [{119, 129, 152}],
        ep1: [%{style: "req", read: "Job 20"}],
        ep2: [%{style: "req", read: "Heb 10:19-end"}],
        epp: [{119, 153, 176}]
      },
      "April23" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 20"}],
        mp2: [%{style: "req", read: "Mark 14:26-52"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Job 21"}],
        ep2: [%{style: "req", read: "Heb 11"}],
        epp: [{120, 1, 999}, {121, 1, 999}]
      },
      "April24" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 21"}],
        mp2: [%{style: "req", read: "Mark 14:53-end"}],
        mpp: [{122, 1, 999}, {123, 1, 999}],
        ep1: [%{style: "req", read: "Job 22"}],
        ep2: [%{style: "req", read: "Heb 12:1-17"}],
        epp: [{124, 1, 999}, {125, 1, 999}, {126, 1, 999}]
      },
      "April25" => %{
        title: "Mark",
        mp1: [%{style: "req", read: "Acts 12:11-25"}],
        mp2: [%{style: "req", read: "Mark 15"}],
        mpp: [{127, 1, 999}, {128, 1, 999}],
        ep1: [%{style: "req", read: "Job 23"}],
        ep2: [%{style: "req", read: "Heb 12:18-end"}],
        epp: [{129, 1, 999}, {130, 1, 999}, {131, 1, 999}]
      },
      "April26" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 22"}],
        mp2: [%{style: "req", read: "Mark 16"}],
        mpp: [{132, 1, 999}, {133, 1, 999}],
        ep1: [%{style: "req", read: "Job 24"}],
        ep2: [%{style: "req", read: "Heb 13"}],
        epp: [{134, 1, 999}, {135, 1, 999}]
      },
      "April27" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 23"}],
        mp2: [%{style: "req", read: "Luke 1:1-23"}],
        mpp: [{136, 1, 999}],
        ep1: [%{style: "req", read: "Job 25 & 26"}],
        ep2: [%{style: "req", read: "Jas 1"}],
        epp: [{137, 1, 999}, {138, 1, 999}]
      },
      "April28" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 24"}],
        mp2: [%{style: "req", read: "Luke 1:24-56"}],
        mpp: [{139, 1, 999}],
        ep1: [%{style: "req", read: "Job 27"}],
        ep2: [%{style: "req", read: "Jas 2:1-13"}],
        epp: [{141, 1, 999}, {142, 1, 999}]
      },
      "April29" => %{
        title: "",
        mp1: [%{style: "req", read: "Num 25"}],
        mp2: [%{style: "req", read: "Luke 1:57-end"}],
        mpp: [{140, 1, 999}],
        ep1: [%{style: "req", read: "Job 28"}],
        ep2: [%{style: "req", read: "Jas 2:14-end"}],
        epp: [{143, 1, 999}]
      },
      "April30" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 1"}],
        mp2: [%{style: "req", read: "Luke 2:1-21"}],
        mpp: [{144, 1, 999}],
        ep1: [%{style: "req", read: "Job 29"}],
        ep2: [%{style: "req", read: "Jas 3"}],
        epp: [{145, 1, 999}]
      },
      "May01" => %{
        title: "Sts. Philip And James",
        mp1: [%{style: "req", read: "Deut 2"}],
        mp2: [%{style: "req", read: "Luke 2:22-end"}],
        mpp: [{146, 1, 999}],
        ep1: [%{style: "req", read: "Jas 4"}],
        ep2: [%{style: "req", read: "John 1:43-end"}],
        epp: [{147, 1, 999}]
      },
      "May02" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 3"}],
        mp2: [%{style: "req", read: "Luke 3:1-22"}],
        mpp: [{148, 1, 999}],
        ep1: [%{style: "req", read: "Job 30"}],
        ep2: [%{style: "req", read: "Jas 5"}],
        epp: [{149, 1, 999}, {150, 1, 999}]
      },
      "May03" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 4"}],
        mp2: [%{style: "req", read: "Luke 3:23-end"}],
        mpp: [{1, 1, 999}, {2, 1, 999}],
        ep1: [%{style: "req", read: "Job 31"}],
        ep2: [%{style: "req", read: "1 Pet 1:1-21"}],
        epp: [{3, 1, 999}, {4, 1, 999}]
      },
      "May04" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 5"}],
        mp2: [%{style: "req", read: "Luke 4:1-30"}],
        mpp: [{5, 1, 999}, {6, 1, 999}],
        ep1: [%{style: "req", read: "Job 32"}],
        ep2: [%{style: "req", read: "1 Pet 1:22-end, 2:1-10"}],
        epp: [{7, 1, 999}]
      },
      "May05" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 6"}],
        mp2: [%{style: "req", read: "Luke 4:31-end"}],
        mpp: [{9, 1, 999}],
        ep1: [%{style: "req", read: "Job 33"}],
        ep2: [%{style: "req", read: "1 Pet 2:11-end, 3:1-7"}],
        epp: [{10, 1, 999}]
      },
      "May06" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 7"}],
        mp2: [%{style: "req", read: "Luke 5:1-16"}],
        mpp: [{8, 1, 999}, {11, 1, 999}],
        ep1: [%{style: "req", read: "Job 34"}],
        ep2: [%{style: "req", read: "1 Pet 3:8-end, 4:1-6"}],
        epp: [{15, 1, 999}, {16, 1, 999}]
      },
      "May07" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 8"}],
        mp2: [%{style: "req", read: "Luke 5:17-end"}],
        mpp: [{12, 1, 999}, {13, 1, 999}, {14, 1, 999}],
        ep1: [%{style: "req", read: "Job 35"}],
        ep2: [%{style: "req", read: "1 Pet 4:7-end"}],
        epp: [{17, 1, 999}]
      },
      "May08" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 9"}],
        mp2: [%{style: "req", read: "Luke 6:1-19"}],
        mpp: [{18, 1, 20}],
        ep1: [%{style: "req", read: "Job 36"}],
        ep2: [%{style: "req", read: "1 Pet 5"}],
        epp: [{18, 21, 50}]
      },
      "May09" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 10"}],
        mp2: [%{style: "req", read: "Luke 6:20-38"}],
        mpp: [{20, 1, 999}, {21, 1, 999}],
        ep1: [%{style: "req", read: "Job 37"}],
        ep2: [%{style: "req", read: "2 Pet 1"}],
        epp: [{22, 1, 999}]
      },
      "May10" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 11"}],
        mp2: [%{style: "req", read: "Luke 6:39-end, 7:1-10"}],
        mpp: [{19, 1, 999}, {23, 1, 999}],
        ep1: [%{style: "req", read: "Job 38"}],
        ep2: [%{style: "req", read: "2 Pet 2"}],
        epp: [{25, 1, 999}]
      },
      "May11" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 12"}],
        mp2: [%{style: "req", read: "Luke 7:11-35"}],
        mpp: [{24, 1, 999}, {26, 1, 999}],
        ep1: [%{style: "req", read: "Job 39"}],
        ep2: [%{style: "req", read: "2 Pet 3"}],
        epp: [{27, 1, 999}]
      },
      "May12" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 13"}],
        mp2: [%{style: "req", read: "Luke 7:36-end"}],
        mpp: [{28, 1, 999}, {29, 1, 999}],
        ep1: [%{style: "req", read: "Job 40"}],
        ep2: [%{style: "req", read: "Jude"}],
        epp: [{31, 1, 99}]
      },
      "May13" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 14"}],
        mp2: [%{style: "req", read: "Luke 8:1-21"}],
        mpp: [{30, 1, 999}, {32, 1, 999}],
        ep1: [%{style: "req", read: "Job 41"}],
        ep2: [%{style: "req", read: "1 John 1:1-end, 2:1-6"}],
        epp: [{33, 1, 999}]
      },
      "May14" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 15"}],
        mp2: [%{style: "req", read: "Luke 8:22-end"}],
        mpp: [{34, 1, 999}],
        ep1: [%{style: "req", read: "Job 42"}],
        ep2: [%{style: "req", read: "1 John 2:7-end"}],
        epp: [{35, 1, 999}]
      },
      "May15" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 16"}],
        mp2: [%{style: "req", read: "Luke 9:1-17"}],
        mpp: [{36, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 1"}],
        ep2: [%{style: "req", read: "1 John 3:1-10"}],
        epp: [{38, 1, 999}]
      },
      "May16" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 17"}],
        mp2: [%{style: "req", read: "Luke 9:18-50"}],
        mpp: [{37, 1, 18}],
        ep1: [%{style: "req", read: "Eccl 2"}],
        ep2: [%{style: "req", read: "1 John 3:11-end, 4:1-6"}],
        epp: [{37, 19, 42}]
      },
      "May17" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 18"}],
        mp2: [%{style: "req", read: "Luke 9:51-end"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 3"}],
        ep2: [%{style: "req", read: "1 John 4:7-end"}],
        epp: [{39, 1, 999}, {41, 1, 999}]
      },
      "May18" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 19"}],
        mp2: [%{style: "req", read: "Luke 10:1-24"}],
        mpp: [{42, 1, 999}, {43, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 4"}],
        ep2: [%{style: "req", read: "1 John 5"}],
        epp: [{44, 1, 999}]
      },
      "May19" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 20"}],
        mp2: [%{style: "req", read: "Luke 10:25-end"}],
        mpp: [{45, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 5"}],
        ep2: [%{style: "req", read: "2 John"}],
        epp: [{46, 1, 999}]
      },
      "May20" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 21"}],
        mp2: [%{style: "req", read: "Luke 11:1-28"}],
        mpp: [{47, 1, 999}, {48, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 6"}],
        ep2: [%{style: "req", read: "3 John"}],
        epp: [{49, 1, 999}]
      },
      "May21" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 22"}],
        mp2: [%{style: "req", read: "Luke 11:29-end"}],
        mpp: [{50, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 7 "}],
        ep2: [%{style: "req", read: "Gal 1"}],
        epp: [{51, 1, 999}]
      },
      "May22" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 23"}],
        mp2: [%{style: "req", read: "Luke 12:1-34"}],
        mpp: [{52, 1, 999}, {53, 1, 999}, {54, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 8"}],
        ep2: [%{style: "req", read: "Gal 2"}],
        epp: [{55, 1, 999}]
      },
      "May23" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 24"}],
        mp2: [%{style: "req", read: "Luke 12:35-53"}],
        mpp: [{56, 1, 999}, {57, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 9"}],
        ep2: [%{style: "req", read: "Gal 3"}],
        epp: [{58, 1, 999}, {60, 1, 999}]
      },
      "May24" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 25"}],
        mp2: [%{style: "req", read: "Luke 12:54-end, 13:1-9"}],
        mpp: [{59, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 10"}],
        ep2: [%{style: "req", read: "Gal 4"}],
        epp: [{63, 1, 999}, {64, 1, 999}]
      },
      "May25" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 26"}],
        mp2: [%{style: "req", read: "Luke 13:10-end"}],
        mpp: [{61, 1, 999}, {62, 1, 999}],
        ep1: [%{style: "req", read: "Eccl 11"}],
        ep2: [%{style: "req", read: "Gal 5"}],
        epp: [{65, 1, 999}, {67, 1, 999}]
      },
      "May26" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 27"}],
        mp2: [%{style: "req", read: "Luke 14:1-24"}],
        mpp: [{68, 1, 18}],
        ep1: [%{style: "req", read: "Eccl 12"}],
        ep2: [%{style: "req", read: "Gal 6"}],
        epp: [{68, 19, 36}]
      },
      "May27" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 28"}],
        mp2: [%{style: "req", read: "Luke 14:25-end, 15:1-10"}],
        mpp: [{69, 1, 19}],
        ep1: [%{style: "req", read: "Ezek 1"}],
        ep2: [%{style: "req", read: "1 Thess 1"}],
        epp: [{69, 20, 38}]
      },
      "May28" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 29"}],
        mp2: [%{style: "req", read: "Luke 15:11-end"}],
        mpp: [{66, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 2"}],
        ep2: [%{style: "req", read: "1 Thess 2:1-16"}],
        epp: [{70, 1, 999}, {72, 1, 999}]
      },
      "May29" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 30"}],
        mp2: [%{style: "req", read: "Luke 16"}],
        mpp: [{71, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 3"}],
        ep2: [%{style: "req", read: "1 Thess 2:17-end, 3:1-end"}],
        epp: [{73, 1, 999}]
      },
      "May30" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 31"}],
        mp2: [%{style: "req", read: "Luke 17:1-19"}],
        mpp: [{74, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 4"}],
        ep2: [%{style: "req", read: "1 Thess 4:1-12"}],
        epp: [{75, 1, 999}, {76, 1, 999}]
      },
      "May31" => %{
        title: "Visitation",
        mp1: [%{style: "req", read: "Deut 32"}],
        mp2: [%{style: "req", read: "Luke 1:39-56"}],
        mpp: [{77, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 5"}],
        ep2: [%{style: "req", read: "1 Thess 4:13-end, 5:1-11"}],
        epp: [{79, 1, 999}, {82, 1, 999}]
      },
      "June01" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 33"}],
        mp2: [%{style: "req", read: "Luke 17:20-end"}],
        mpp: [{78, 1, 17}],
        ep1: [%{style: "req", read: "Ezek 6"}],
        ep2: [%{style: "req", read: "1 Thess 5:12-end"}],
        epp: [{78, 18, 39}]
      },
      "June02" => %{
        title: "",
        mp1: [%{style: "req", read: "Deut 34"}],
        mp2: [%{style: "req", read: "Luke 18:1-30"}],
        mpp: [{78, 41, 73}],
        ep1: [%{style: "req", read: "Ezek 7"}],
        ep2: [%{style: "req", read: "2 Thess 1"}],
        epp: [{80, 1, 999}]
      },
      "June03" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 1"}],
        mp2: [%{style: "req", read: "Luke 18:31-end, 19:1-10"}],
        mpp: [{81, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 8"}],
        ep2: [%{style: "req", read: "2 Thess 2"}],
        epp: [{83, 1, 999}]
      },
      "June04" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 2"}],
        mp2: [%{style: "req", read: "Luke 19:11-28"}],
        mpp: [{84, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 9"}],
        ep2: [%{style: "req", read: "2 Thess 3"}],
        epp: [{85, 1, 999}]
      },
      "June05" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 3"}],
        mp2: [%{style: "req", read: "Luke 19:29-end"}],
        mpp: [{86, 1, 999}, {87, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 10"}],
        ep2: [%{style: "req", read: "1 Cor 1:1-25"}],
        epp: [{88, 1, 999}]
      },
      "June06" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 4"}],
        mp2: [%{style: "req", read: "Luke 20:1-26"}],
        mpp: [{89, 1, 18}],
        ep1: [%{style: "req", read: "Ezek 11"}],
        ep2: [%{style: "req", read: "1 Cor 1:26-end, 2:1-end"}],
        epp: [{89, 19, 52}]
      },
      "June07" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 5"}],
        mp2: [%{style: "req", read: "Luke 20:27-end, 21:1-4"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 12"}],
        ep2: [%{style: "req", read: "1 Cor 3"}],
        epp: [{91, 1, 999}]
      },
      "June08" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 6"}],
        mp2: [%{style: "req", read: "Luke 21:5-end"}],
        mpp: [{92, 1, 999}, {93, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 13"}],
        ep2: [%{style: "req", read: "1 Cor 4:1-17"}],
        epp: [{94, 1, 999}]
      },
      "June09" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 7"}],
        mp2: [%{style: "req", read: "Luke 22:1-38"}],
        mpp: [{95, 1, 999}, {96, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 14"}],
        ep2: [%{style: "req", read: "1 Cor 4:18-end, 5:1-end"}],
        epp: [{97, 1, 999}, {98, 1, 999}]
      },
      "June10" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 8"}],
        mp2: [%{style: "req", read: "Luke 22:39-53"}],
        mpp: [{99, 1, 999}, {100, 1, 999}, {101, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 15"}],
        ep2: [%{style: "req", read: "1 Cor 6"}],
        epp: [{102, 1, 999}]
      },
      "June11" => %{
        title: "Barnabas",
        mp1: [%{style: "req", read: "Acts 4"}],
        mp2: [%{style: "req", read: "Luke 22:54-end"}],
        mpp: [{103, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 16"}],
        ep2: [%{style: "req", read: "1 Cor 7"}],
        epp: [{104, 1, 999}]
      },
      "June12" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 9"}],
        mp2: [%{style: "req", read: "Luke 23:1-25"}],
        mpp: [{105, 1, 22}],
        ep1: [%{style: "req", read: "Ezek 17"}],
        ep2: [%{style: "req", read: "1 Cor 8"}],
        epp: [{105, 23, 45}]
      },
      "June13" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 10"}],
        mp2: [%{style: "req", read: "Luke:23:26-49"}],
        mpp: [{106, 1, 18}],
        ep1: [%{style: "req", read: "Ezek 18"}],
        ep2: [%{style: "req", read: "1 Cor 9"}],
        epp: [{106, 19, 48}]
      },
      "June14" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 14"}],
        mp2: [%{style: "req", read: "Luke 23:50-end, 24:1-12"}],
        mpp: [{107, 1, 22}],
        ep1: [%{style: "req", read: "Ezek 33"}],
        ep2: [%{style: "req", read: "1 Cor 10"}],
        epp: [{107, 23, 43}]
      },
      "June15" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 22"}],
        mp2: [%{style: "req", read: "Luke 24:13-end"}],
        mpp: [{108, 1, 999}, {110, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 34"}],
        ep2: [%{style: "req", read: "1 Cor 11"}],
        epp: [{109, 1, 999}]
      },
      "June16" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 23"}],
        mp2: [%{style: "req", read: "Acts 1:1-14"}],
        mpp: [{111, 1, 999}, {112, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 35"}],
        ep2: [%{style: "req", read: "1 Cor 12"}],
        epp: [{113, 1, 999}, {114, 1, 999}]
      },
      "June17" => %{
        title: "",
        mp1: [%{style: "req", read: "Josh 24"}],
        mp2: [%{style: "req", read: "Acts 1:15-end"}],
        mpp: [{115, 1, 999}],
        ep1: [%{style: "req", read: "Ezek 36 "}],
        ep2: [%{style: "req", read: "1 Cor 13"}],
        epp: [{116, 1, 999}, {117, 1, 999}]
      },
      "June18" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 1:1-21"}, %{style: "opt", read: "Judg 1:22-999"}],
        mp2: [%{style: "req", read: "Acts 2:1-21"}],
        mpp: [{119, 1, 24}],
        ep1: [%{style: "req", read: "Ezek 37"}],
        ep2: [%{style: "req", read: "1 Cor 14:1-19"}],
        epp: [{119, 25, 48}]
      },
      "June19" => %{
        title: "",
        mp1: [%{style: "opt", read: "Judg 2:1-5"}, %{style: "req", read: "Judg 2:6-23"}],
        mp2: [%{style: "req", read: "Acts 2:22-end"}],
        mpp: [{119, 49, 72}],
        ep1: [
          %{style: "req", read: "Ezek 40:1-5"},
          %{style: "opt", read: "Ezek 40:6-16"},
          %{style: "req", read: "Ezek 40:17-19"},
          %{style: "opt", read: "Ezek 40:20-34"},
          %{style: "req", read: "Ezek 40:35-49"}
        ],
        ep2: [%{style: "req", read: "1 Cor 14:20-end"}],
        epp: [{119, 73, 88}]
      },
      "June20" => %{
        title: "",
        mp1: [
          %{style: "opt", read: "Judg 3:1-6"},
          %{style: "req", read: "Judg 3:7-30"},
          %{style: "opt", read: "Judg 3:31"}
        ],
        mp2: [%{style: "req", read: "Acts 3:1-end, 4:1-4"}],
        mpp: [{119, 89, 104}],
        ep1: [%{style: "req", read: "Ezek 43"}],
        ep2: [%{style: "req", read: "1 Cor 15:1-34"}],
        epp: [{119, 105, 128}]
      },
      "June21" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 4"}],
        mp2: [%{style: "req", read: "Acts 4:5-31"}],
        mpp: [{119, 129, 152}],
        ep1: [%{style: "req", read: "Ezek 47"}],
        ep2: [%{style: "req", read: "1 Cor 15:35-end"}],
        epp: [{119, 153, 176}]
      },
      "June22" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 5:1-5"}, %{style: "opt", read: "Judg 5:19-31"}],
        mp2: [%{style: "req", read: "Acts 4:32-end, 5:1-11"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Dan 1"}],
        ep2: [%{style: "req", read: "1 Cor 16"}],
        epp: [{120, 1, 999}, {121, 1, 999}]
      },
      "June23" => %{
        title: "",
        mp1: [
          %{style: "req", read: "Judg 6:1-6"},
          %{style: "opt", read: "Judg 6:7-10"},
          %{style: "req", read: "Judg 6:11-24"},
          %{style: "opt", read: "Judg 6:25-32"},
          %{style: "req", read: "Judg 6:33-40"}
        ],
        mp2: [%{style: "req", read: "Acts 5:12-end"}],
        mpp: [{122, 1, 999}, {123, 1, 999}],
        ep1: [
          %{style: "req", read: "Dan 2:1-14"},
          %{style: "opt", read: "Dan 2:15-24"},
          %{style: "req", read: "Dan 2:25-28"},
          %{style: "opt", read: "Dan 2:29-30"},
          %{style: "req", read: "Dan 2:31-45"},
          %{style: "opt", read: "Dan 2:46-49"}
        ],
        ep2: [%{style: "req", read: "2 Cor 1:1-end, 2:1-11"}],
        epp: [{124, 1, 999}, {125, 1, 999}, {126, 1, 999}]
      },
      "June24" => %{
        title: "Nativity Of John The Baptist",
        mp1: [%{style: "req", read: "Acts 6:1-end, 7:1-16"}],
        mp2: [%{style: "req", read: "Matt 14:1-13"}],
        mpp: [{127, 1, 999}, {128, 1, 999}],
        ep1: [%{style: "req", read: "Dan 3"}],
        ep2: [%{style: "req", read: "2 Cor 2 12-end, 3:1-end"}],
        epp: [{129, 1, 999}, {130, 1, 999}, {131, 1, 999}]
      },
      "June25" => %{
        title: "",
        mp1: [
          %{style: "req", read: "Judg 7:1-8"},
          %{style: "opt", read: "Judg 7:9-15"},
          %{style: "req", read: "Judg 7:16-25"}
        ],
        mp2: [%{style: "req", read: "Acts 7:17-34"}],
        mpp: [{132, 1, 999}, {133, 1, 999}],
        ep1: [
          %{style: "req", read: "Dan 4:1-9"},
          %{style: "opt", read: "Dan 4:10-18"},
          %{style: "req", read: "Dan 4:19-35"},
          %{style: "opt", read: "Dan 4:36-37"}
        ],
        ep2: [%{style: "req", read: "2 Cor 4"}],
        epp: [{134, 1, 999}, {135, 1, 999}]
      },
      "June26" => %{
        title: "",
        mp1: [
          %{style: "opt", read: "Judg 8:1-3"},
          %{style: "req", read: "Judg 8:4-23"},
          %{style: "opt", read: "Judg 8:24-27"},
          %{style: "req", read: "Judg 8:28"},
          %{style: "opt", read: "Judg 8:29-35"}
        ],
        mp2: [%{style: "req", read: "Acts 7:35-end, 8:1-3"}],
        mpp: [{136, 1, 999}],
        ep1: [%{style: "req", read: "Dan 5 "}],
        ep2: [%{style: "req", read: "2 Cor 5"}],
        epp: [{137, 1, 999}, {138, 1, 999}]
      },
      "June27" => %{
        title: "",
        mp1: [
          %{style: "req", read: "Judg 9:1-6"},
          %{style: "opt", read: "Judg 9:7-21"},
          %{style: "req", read: "Judg 9:22-25"},
          %{style: "opt", read: "Judg 9:26-42"},
          %{style: "req", read: "Judg 9:43-56"},
          %{style: "opt", read: "Judg 9:57"}
        ],
        mp2: [%{style: "req", read: "Acts 8:4-25"}],
        mpp: [{139, 1, 999}],
        ep1: [%{style: "req", read: "Dan 6"}],
        ep2: [%{style: "req", read: "2 Cor 6"}],
        epp: [{141, 1, 999}, {142, 1, 999}]
      },
      "June28" => %{
        title: "",
        mp1: [%{style: "opt", read: "Judg 10:1-5"}, %{style: "req", read: "Judg 10:6-18"}],
        mp2: [%{style: "req", read: "Acts 8:26-end"}],
        mpp: [{140, 1, 999}],
        ep1: [%{style: "req", read: "Dan 7"}],
        ep2: [%{style: "req", read: "2 Cor 7"}],
        epp: [{143, 1, 999}]
      },
      "June29" => %{
        title: "Sts. Peter And Paul",
        mp1: [%{style: "req", read: "Acts 15:1-35"}],
        mp2: [%{style: "req", read: "2 Pet 3:14-end"}],
        mpp: [{144, 1, 999}],
        ep1: [%{style: "req", read: "Dan 8"}],
        ep2: [%{style: "req", read: "2 Cor 8"}],
        epp: [{145, 1, 999}]
      },
      "June30" => %{
        title: "",
        mp1: [
          %{style: "req", read: "Judg 11:1-11"},
          %{style: "opt", read: "Judg 11:12-28"},
          %{style: "req", read: "Judg 11:29-40"}
        ],
        mp2: [%{style: "req", read: "Acts 9:32-end"}],
        mpp: [{146, 1, 999}],
        ep1: [%{style: "req", read: "Dan 9"}],
        ep2: [%{style: "req", read: "2 Cor 9"}],
        epp: [{147, 1, 999}]
      },
      "July01" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 12"}],
        mp2: [%{style: "req", read: "Acts 10:1-23"}],
        mpp: [{148, 1, 999}],
        ep1: [%{style: "req", read: "Dan 10"}],
        ep2: [%{style: "req", read: "2 Cor 10"}],
        epp: [{149, 1, 999}, {150, 1, 999}]
      },
      "July02" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 13"}],
        mp2: [%{style: "req", read: "Acts 10:24-end"}],
        mpp: [{1, 1, 999}, {2, 1, 999}],
        ep1: [%{style: "req", read: "Dan 11:1-19"}, %{style: "opt", read: "Dan 11:20-999"}],
        ep2: [%{style: "req", read: "2 Cor 11"}],
        epp: [{3, 1, 999}, {4, 1, 999}]
      },
      "July03" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 14"}],
        mp2: [%{style: "req", read: "Acts 11:1-18"}],
        mpp: [{5, 1, 999}, {6, 1, 999}],
        ep1: [%{style: "req", read: "Dan 12"}],
        ep2: [%{style: "req", read: "2 Cor 12:1-13"}],
        epp: [{7, 1, 999}]
      },
      "July04" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 15"}],
        mp2: [%{style: "req", read: "Acts 11:19-end"}],
        mpp: [{9, 1, 999}],
        ep1: [%{style: "req", read: "Susanna"}],
        ep2: [%{style: "req", read: "2 Cor 12:14-end, 13:1-end"}],
        epp: [{10, 1, 999}]
      },
      "July05" => %{
        title: "",
        mp1: [%{style: "req", read: "Judg 16"}],
        mp2: [%{style: "req", read: "Acts 12:1-24"}],
        mpp: [{8, 1, 999}, {11, 1, 999}],
        ep1: [%{style: "req", read: "Esth 1"}],
        ep2: [%{style: "req", read: "Rom 1"}],
        epp: [{15, 1, 999}, {16, 1, 999}]
      },
      "July06" => %{
        title: "",
        mp1: [%{style: "req", read: "Ruth 1"}],
        mp2: [%{style: "req", read: "Acts 12:25-end, 13:1-12"}],
        mpp: [{12, 1, 999}, {13, 1, 999}, {14, 1, 999}],
        ep1: [%{style: "req", read: "Esth 2"}],
        ep2: [%{style: "req", read: "Rom 2"}],
        epp: [{17, 1, 999}]
      },
      "July07" => %{
        title: "",
        mp1: [%{style: "req", read: "Ruth 2"}],
        mp2: [%{style: "req", read: "Acts 13:13-43"}],
        mpp: [{18, 1, 20}],
        ep1: [%{style: "req", read: "Esth 3"}],
        ep2: [%{style: "req", read: "Rom 3"}],
        epp: [{18, 21, 50}]
      },
      "July08" => %{
        title: "",
        mp1: [%{style: "req", read: "Ruth 3"}],
        mp2: [%{style: "req", read: "Acts 13:44-end, 14:1-7"}],
        mpp: [{20, 1, 999}, {21, 1, 999}],
        ep1: [%{style: "req", read: "Esth 4"}],
        ep2: [%{style: "req", read: "Rom 4"}],
        epp: [{22, 1, 999}]
      },
      "July09" => %{
        title: "",
        mp1: [%{style: "req", read: "Ruth 4"}],
        mp2: [%{style: "req", read: "Acts 14:8-end"}],
        mpp: [{19, 1, 999}, {23, 1, 999}],
        ep1: [%{style: "req", read: "Esth 5"}],
        ep2: [%{style: "req", read: "Rom 5"}],
        epp: [{25, 1, 999}]
      },
      "July10" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 1:1-20"}, %{style: "opt", read: "1 Sam 1:21-999"}],
        mp2: [%{style: "req", read: "Acts 15:1-21"}],
        mpp: [{24, 1, 999}, {26, 1, 999}],
        ep1: [%{style: "req", read: "Esth 6"}],
        ep2: [%{style: "req", read: "Rom 6"}],
        epp: [{27, 1, 999}]
      },
      "July11" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 2:1-21"}, %{style: "opt", read: "1 Sam 2:22-999"}],
        mp2: [%{style: "req", read: "Acts 15:22-35"}],
        mpp: [{28, 1, 999}, {29, 1, 999}],
        ep1: [%{style: "req", read: "Esth 7"}],
        ep2: [%{style: "req", read: "Rom 7"}],
        epp: [{31, 1, 99}]
      },
      "July12" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 3"}],
        mp2: [%{style: "req", read: "Acts 15:36-end, 16:1-5"}],
        mpp: [{30, 1, 999}, {32, 1, 999}],
        ep1: [%{style: "req", read: "Esth 8"}],
        ep2: [%{style: "req", read: "Rom 8:1-17"}],
        epp: [{33, 1, 999}]
      },
      "July13" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 4"}],
        mp2: [%{style: "req", read: "Acts 16:6-end"}],
        mpp: [{34, 1, 999}],
        ep1: [
          %{style: "req", read: "Esth 9:1-22"},
          %{style: "opt", read: "Esth 9:23-999"},
          %{style: "req", read: "Esth 10"}
        ],
        ep2: [%{style: "req", read: "Rom 8:18-end"}],
        epp: [{35, 1, 999}]
      },
      "July14" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 5"}],
        mp2: [%{style: "req", read: "Acts 17:1-15"}],
        mpp: [{36, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 1"}],
        ep2: [%{style: "req", read: "Rom 9"}],
        epp: [{38, 1, 999}]
      },
      "July15" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 6:1-15"}, %{style: "opt", read: "1 Sam 6:16-999"}],
        mp2: [%{style: "req", read: "Acts 17:16-end"}],
        mpp: [{37, 1, 18}],
        ep1: [%{style: "req", read: "Ezra 3"}],
        ep2: [%{style: "req", read: "Rom 10"}],
        epp: [{37, 19, 42}]
      },
      "July16" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 7"}],
        mp2: [%{style: "req", read: "Acts 18:1-23"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 4:1-21"}, %{style: "opt", read: "Ezra 4:22-999"}],
        ep2: [%{style: "req", read: "Rom 11"}],
        epp: [{39, 1, 999}, {41, 1, 999}]
      },
      "July17" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 8"}],
        mp2: [%{style: "req", read: "Acts 18:24-end, 19:1-7"}],
        mpp: [{42, 1, 999}, {43, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 5"}],
        ep2: [%{style: "req", read: "Rom 12"}],
        epp: [{44, 1, 999}]
      },
      "July18" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 9"}],
        mp2: [%{style: "req", read: "Acts 19:8-20"}],
        mpp: [{45, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 6"}],
        ep2: [%{style: "req", read: "Rom 13"}],
        epp: [{46, 1, 999}]
      },
      "July19" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 10"}],
        mp2: [%{style: "req", read: "Acts 19:21-end"}],
        mpp: [{47, 1, 999}, {48, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 7"}],
        ep2: [%{style: "req", read: "Rom 14"}],
        epp: [{49, 1, 999}]
      },
      "July20" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 11"}],
        mp2: [%{style: "req", read: "Acts 20:1-16"}],
        mpp: [{50, 1, 999}],
        ep1: [%{style: "opt", read: "Ezra 8:1-20"}, %{style: "req", read: "Ezra 8:21-36"}],
        ep2: [%{style: "req", read: "Rom 15"}],
        epp: [{51, 1, 999}]
      },
      "July21" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 12 "}],
        mp2: [%{style: "req", read: "Acts 20:17-end"}],
        mpp: [{52, 1, 999}, {53, 1, 999}, {54, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 9"}],
        ep2: [%{style: "req", read: "Rom 16"}],
        epp: [{55, 1, 999}]
      },
      "July22" => %{
        title: "Mary Mag.",
        mp1: [%{style: "req", read: "Acts 21:1-16"}],
        mp2: [%{style: "req", read: "Luke 7:36-50"}],
        mpp: [{56, 1, 999}, {57, 1, 999}],
        ep1: [%{style: "req", read: "Ezra 10:1-16"}, %{style: "opt", read: "Ezra 10:17-999"}],
        ep2: [%{style: "req", read: "John 1:1-28"}],
        epp: [{58, 1, 999}, {60, 1, 999}]
      },
      "July23" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 13"}],
        mp2: [%{style: "req", read: "Acts 21:17-36"}],
        mpp: [{59, 1, 999}],
        ep1: [%{style: "req", read: "Neh 1"}],
        ep2: [%{style: "req", read: "John 1:29-end"}],
        epp: [{63, 1, 999}, {64, 1, 999}]
      },
      "July24" => %{
        title: "",
        mp1: [
          %{style: "req", read: "1 Sam 14:1-15"},
          %{style: "opt", read: "1 Sam 14:16-19"},
          %{style: "req", read: "1 Sam 14:20"},
          %{style: "opt", read: "1 Sam 14:21-23"},
          %{style: "req", read: "1 Sam 14:24-30"},
          %{style: "opt", read: "1 Sam 14:31-52"}
        ],
        mp2: [%{style: "req", read: "Acts 21:37-end, 22:1-22"}],
        mpp: [{61, 1, 999}, {62, 1, 999}],
        ep1: [%{style: "req", read: "Neh 2"}],
        ep2: [%{style: "req", read: "John 2"}],
        epp: [{65, 1, 999}, {67, 1, 999}]
      },
      "July25" => %{
        title: "James",
        mp1: [%{style: "req", read: "Acts 22:23-end, 23:1-11"}],
        mp2: [%{style: "req", read: "Mark 1:16-20"}],
        mpp: [{68, 1, 18}],
        ep1: [%{style: "req", read: "Neh 3:1-15"}, %{style: "opt", read: "Neh 3:16-999"}],
        ep2: [%{style: "req", read: "John 3:1-21"}],
        epp: [{68, 19, 36}]
      },
      "July26" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 15"}],
        mp2: [%{style: "req", read: "Acts 23:12-end"}],
        mpp: [{69, 1, 19}],
        ep1: [%{style: "req", read: "Neh 4"}],
        ep2: [%{style: "req", read: "John 3:22-end"}],
        epp: [{69, 20, 38}]
      },
      "July27" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 16"}],
        mp2: [%{style: "req", read: "Acts 24:1-23"}],
        mpp: [{66, 1, 999}],
        ep1: [%{style: "req", read: "Neh 5"}],
        ep2: [%{style: "req", read: "John 4:1-26"}],
        epp: [{70, 1, 999}, {72, 1, 999}]
      },
      "July28" => %{
        title: "",
        mp1: [
          %{style: "req", read: "1 Sam 17:1-11"},
          %{style: "opt", read: "1 Sam 17:12-25"},
          %{style: "req", read: "1 Sam 17:26-27"},
          %{style: "opt", read: "1 Sam 17:28-30"},
          %{style: "req", read: "1 Sam 17:31-51"},
          %{style: "opt", read: "1 Sam 17:52-57"}
        ],
        mp2: [%{style: "req", read: "Acts 24:24-end, 25:1-12"}],
        mpp: [{71, 1, 999}],
        ep1: [%{style: "req", read: "Neh 6"}],
        ep2: [%{style: "req", read: "John 4:27-end"}],
        epp: [{73, 1, 999}]
      },
      "July29" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 18"}],
        mp2: [%{style: "req", read: "Acts 25:13-end"}],
        mpp: [{74, 1, 999}],
        ep1: [%{style: "req", read: "Neh 8"}],
        ep2: [%{style: "req", read: "John 5:1-24"}],
        epp: [{75, 1, 999}, {76, 1, 999}]
      },
      "July30" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 19"}],
        mp2: [%{style: "req", read: "Acts 26"}],
        mpp: [{77, 1, 999}],
        ep1: [
          %{style: "req", read: "Neh 9:1-15"},
          %{style: "opt", read: "Neh 9:16-25"},
          %{style: "req", read: "Neh 9:26-38"}
        ],
        ep2: [%{style: "req", read: "John 5:25-end"}],
        epp: [{79, 1, 999}, {82, 1, 999}]
      },
      "July31" => %{
        title: "",
        mp1: [
          %{style: "req", read: "1 Sam 20:1-7"},
          %{style: "opt", read: "1 Sam 20:8-23"},
          %{style: "req", read: "1 Sam 20:24-42"}
        ],
        mp2: [%{style: "req", read: "Acts 27"}],
        mpp: [{78, 1, 17}],
        ep1: [%{style: "opt", read: "Neh 10:1-28"}, %{style: "req", read: "Neh 10:28-39"}],
        ep2: [%{style: "req", read: "John 6:1-21"}],
        epp: [{78, 18, 39}]
      },
      "August01" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 21"}],
        mp2: [%{style: "req", read: "Acts 28:1-15"}],
        epp: [{80, 1, 999}],
        ep1: [%{style: "opt", read: "Neh 12:1-26"}, %{style: "req", read: "Neh 12:27-47"}],
        mpp: [{78, 41, 73}],
        ep2: [%{style: "req", read: "John 6:22-40"}]
      },
      "August02" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 22"}],
        mp2: [%{style: "req", read: "Acts 28:16-end"}],
        epp: [{83, 1, 999}],
        ep1: [
          %{style: "req", read: "Neh 13:1-22"},
          %{style: "opt", read: "Neh 13:23-29"},
          %{style: "req", read: "Neh 13:30-31"}
        ],
        mpp: [{81, 1, 999}],
        ep2: [%{style: "req", read: "John 6:41-end"}]
      },
      "August03" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 23"}],
        mp2: [%{style: "req", read: "Phil 1:1-11"}],
        mpp: [{84, 1, 999}],
        ep1: [%{style: "req", read: "Hos 1"}],
        ep2: [%{style: "req", read: "John 7:1-24"}],
        epp: [{85, 1, 999}]
      },
      "August04" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 24"}],
        mp2: [%{style: "req", read: "Phil 1:12-end"}],
        mpp: [{86, 1, 999}, {87, 1, 999}],
        ep1: [%{style: "req", read: "Hos 2"}],
        ep2: [%{style: "req", read: "John 7:25-52"}],
        epp: [{88, 1, 999}]
      },
      "August05" => %{
        title: "",
        mp1: [
          %{style: "req", read: "1 Sam 25:1-19"},
          %{style: "opt", read: "1 Sam 25:20-22"},
          %{style: "req", read: "1 Sam 25:23-25"},
          %{style: "opt", read: "1 Sam 25:26-31"},
          %{style: "req", read: "1 Sam 25:32-42"},
          %{style: "opt", read: "1 Sam 25:43-44"}
        ],
        mp2: [%{style: "req", read: "Phil 2:1-11"}],
        mpp: [{89, 1, 18}],
        ep1: [%{style: "req", read: "Hos 3"}],
        ep2: [%{style: "req", read: "John 7:53-end, 8:1-30"}],
        epp: [{89, 19, 52}]
      },
      "August06" => %{
        title: "Transfiguration",
        mp1: [%{style: "req", read: "Phil 2:12-end"}],
        mp2: [%{style: "req", read: "Luke 9:28-36"}],
        mpp: [{27, 1, 999}],
        ep1: [%{style: "req", read: "Hos 4"}],
        ep2: [%{style: "req", read: "John 8:31-end"}],
        epp: [{80, 1, 999}]
      },
      "August07" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 26"}],
        mp2: [%{style: "req", read: "Phil 3"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Hos 5"}],
        ep2: [%{style: "req", read: "John 9"}],
        epp: [{91, 1, 999}]
      },
      "August08" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 27"}],
        mp2: [%{style: "req", read: "Phil 4"}],
        mpp: [{92, 1, 999}, {93, 1, 999}],
        ep1: [%{style: "req", read: "Hos 6"}],
        ep2: [%{style: "req", read: "John 10:1-21"}],
        epp: [{94, 1, 999}]
      },
      "August09" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 28"}],
        mp2: [%{style: "req", read: "Col 1:1-20"}],
        mpp: [{95, 1, 999}, {96, 1, 999}],
        ep1: [%{style: "req", read: "Hos 7"}],
        ep2: [%{style: "req", read: "John 10:22-end"}],
        epp: [{97, 1, 999}, {98, 1, 999}]
      },
      "August10" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 29"}],
        mp2: [%{style: "req", read: "Col 1:21-end, 2:1-7"}],
        mpp: [{99, 1, 999}, {100, 1, 999}, {101, 1, 999}],
        ep1: [%{style: "req", read: "Hos 8"}],
        ep2: [%{style: "req", read: "John 11:1-44"}],
        epp: [{102, 1, 999}]
      },
      "August11" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 30:1-25"}, %{style: "opt", read: "1 Sam 30:26-999"}],
        mp2: [%{style: "req", read: "Col 2:8-19"}],
        mpp: [{103, 1, 999}],
        ep1: [%{style: "req", read: "Hos 9"}],
        ep2: [%{style: "req", read: "John 11:45-end"}],
        epp: [{104, 1, 999}]
      },
      "August12" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Sam 31"}],
        mp2: [%{style: "req", read: "Col 2:20-end, 3:1-11"}],
        mpp: [{105, 1, 22}],
        ep1: [%{style: "req", read: "Hos 10"}],
        ep2: [%{style: "req", read: "John 12:1-19"}],
        epp: [{105, 23, 45}]
      },
      "August13" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 1"}],
        mp2: [%{style: "req", read: "Col 3:12-end"}],
        mpp: [{106, 1, 18}],
        ep1: [%{style: "req", read: "Hos 11"}],
        ep2: [%{style: "req", read: "John 12:20-end"}],
        epp: [{106, 19, 48}]
      },
      "August14" => %{
        title: "",
        mp1: [
          %{style: "req", read: "2 Sam 2:1-17"},
          %{style: "opt", read: "2 Sam 2:16-25"},
          %{style: "req", read: "2 Sam 2:26-31"},
          %{style: "opt", read: "2 Sam 2:32"}
        ],
        mp2: [%{style: "req", read: "Col 4"}],
        mpp: [{107, 1, 22}],
        ep1: [%{style: "req", read: "Hos 12"}],
        ep2: [%{style: "req", read: "John 13"}],
        epp: [{107, 23, 43}]
      },
      "August15" => %{
        title: "Blessed Virgin Mary",
        mp1: [
          %{style: "opt", read: "2 Sam 3:1-5"},
          %{style: "req", read: "2 Sam 3:6-11"},
          %{style: "opt", read: "2 Sam 3:12-16"},
          %{style: "req", read: "2 Sam 3:17-39"}
        ],
        mp2: [%{style: "req", read: "Luke 1:26-38"}],
        mpp: [{108, 1, 999}, {110, 1, 999}],
        ep1: [%{style: "req", read: "Hos 13"}],
        ep2: [%{style: "req", read: "John 14:1-14"}],
        epp: [{109, 1, 999}]
      },
      "August16" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 4"}],
        mp2: [%{style: "req", read: "Philemon"}],
        mpp: [{111, 1, 999}, {112, 1, 999}],
        ep1: [%{style: "req", read: "Hos 14"}],
        ep2: [%{style: "req", read: "John 14:15-end"}],
        epp: [{113, 1, 999}, {114, 1, 999}]
      },
      "August17" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 5"}],
        mp2: [%{style: "req", read: "Eph 1:1-14"}],
        mpp: [{115, 1, 999}],
        ep1: [%{style: "req", read: "Joel 1"}],
        ep2: [%{style: "req", read: "John 15:1-17"}],
        epp: [{116, 1, 999}, {117, 1, 999}]
      },
      "August18" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 6"}],
        mp2: [%{style: "req", read: "Eph 1:15-end"}],
        mpp: [{119, 1, 24}],
        ep1: [
          %{style: "req", read: "Joel 2:1-17"},
          %{style: "opt", read: "Joel 2:18-27"},
          %{style: "req", read: "Joel 2:28-32"}
        ],
        ep2: [%{style: "req", read: "John 15:18-end"}],
        epp: [{119, 25, 48}]
      },
      "August19" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 7"}],
        mp2: [%{style: "req", read: "Eph 2:1-10"}],
        mpp: [{119, 49, 72}],
        ep1: [%{style: "req", read: "Joel 3"}],
        ep2: [%{style: "req", read: "John 16:1-15"}],
        epp: [{119, 73, 88}]
      },
      "August20" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 8"}],
        mp2: [%{style: "req", read: "Eph 2:11-end"}],
        mpp: [{119, 89, 104}],
        ep1: [%{style: "req", read: "Amos 1"}],
        ep2: [%{style: "req", read: "John 16:16-end"}],
        epp: [{119, 105, 128}]
      },
      "August21" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 9"}],
        mp2: [%{style: "req", read: "Eph 3"}],
        mpp: [{119, 129, 152}],
        ep1: [%{style: "req", read: "Amos 2"}],
        ep2: [%{style: "req", read: "John 17"}],
        epp: [{119, 153, 176}]
      },
      "August22" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 10"}],
        mp2: [%{style: "req", read: "Eph 4:1-16"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Amos 3"}],
        ep2: [%{style: "req", read: "John 18:1-27"}],
        epp: [{120, 1, 999}, {121, 1, 999}]
      },
      "August23" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 11"}],
        mp2: [%{style: "req", read: "Eph 4:17-end"}],
        mpp: [{122, 1, 999}, {123, 1, 999}],
        ep1: [%{style: "req", read: "Amos 4"}],
        ep2: [%{style: "req", read: "John 18:28-end"}],
        epp: [{124, 1, 999}, {125, 1, 999}, {126, 1, 999}]
      },
      "August24" => %{
        title: "St. Bartholomew",
        mp1: [%{style: "req", read: "Eph 5:1-21"}],
        mp2: [%{style: "req", read: "Luke 6:12-16"}],
        mpp: [{127, 1, 999}, {128, 1, 999}],
        ep1: [%{style: "req", read: "Amos 5"}],
        ep2: [%{style: "req", read: "John 19:1-37"}],
        epp: [{129, 1, 999}, {130, 1, 999}, {131, 1, 999}]
      },
      "August25" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 12"}],
        mp2: [%{style: "req", read: "Eph 5:22-end"}],
        mpp: [{132, 1, 999}, {133, 1, 999}],
        ep1: [%{style: "req", read: "Amos 6"}],
        ep2: [%{style: "req", read: "John 19:38-end"}],
        epp: [{134, 1, 999}, {135, 1, 999}]
      },
      "August26" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 13"}],
        mp2: [%{style: "req", read: "Eph 6:1-9"}],
        mpp: [{136, 1, 999}],
        ep1: [%{style: "req", read: "Amos 7"}],
        ep2: [%{style: "req", read: "John 20"}],
        epp: [{137, 1, 999}, {138, 1, 999}]
      },
      "August27" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 14"}],
        mp2: [%{style: "req", read: "Eph 6:10-end"}],
        mpp: [{139, 1, 999}],
        ep1: [%{style: "req", read: "Amos 8"}],
        ep2: [%{style: "req", read: "John 21"}],
        epp: [{141, 1, 999}, {142, 1, 999}]
      },
      "August28" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 15"}],
        mp2: [%{style: "req", read: "1 Tim 1:1-17"}],
        mpp: [{140, 1, 999}],
        ep1: [%{style: "req", read: "Amos 9"}],
        ep2: [%{style: "req", read: "Matt 1:1-17"}],
        epp: [{143, 1, 999}]
      },
      "August29" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 16"}],
        mp2: [%{style: "req", read: "1 Tim 1:18-2 end"}],
        mpp: [{144, 1, 999}],
        ep1: [%{style: "req", read: "Obadiah"}],
        ep2: [%{style: "req", read: "Matt 1:18-end"}],
        epp: [{145, 1, 999}]
      },
      "August30" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 17"}],
        mp2: [%{style: "req", read: "1 Tim 3"}],
        mpp: [{146, 1, 999}],
        ep1: [%{style: "req", read: "Jonah 1"}],
        ep2: [%{style: "req", read: "Matt 2:1-18"}],
        epp: [{147, 1, 999}]
      },
      "August31" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 18"}],
        mp2: [%{style: "req", read: "1 Tim 4"}],
        mpp: [{148, 1, 999}],
        ep1: [%{style: "req", read: "Jonah 2"}],
        ep2: [%{style: "req", read: "Matt 2:19-end"}],
        epp: [{149, 1, 999}, {150, 1, 999}]
      },
      "September01" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 19"}],
        mp2: [%{style: "req", read: "1 Tim 5"}],
        mpp: [{1, 1, 999}, {2, 1, 999}],
        ep1: [%{style: "req", read: "Jonah 3"}],
        ep2: [%{style: "req", read: "Matt 3"}],
        epp: [{3, 1, 999}, {4, 1, 999}]
      },
      "September02" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 20"}],
        mp2: [%{style: "req", read: "1 Tim 6"}],
        mpp: [{5, 1, 999}, {6, 1, 999}],
        ep1: [%{style: "req", read: "Jonah 4"}],
        ep2: [%{style: "req", read: "Matt 4"}],
        epp: [{7, 1, 999}]
      },
      "September03" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 21"}],
        mp2: [%{style: "req", read: "Titus 1"}],
        mpp: [{9, 1, 999}],
        ep1: [%{style: "req", read: "Mic 1"}],
        ep2: [%{style: "req", read: "Matt 5"}],
        epp: [{10, 1, 999}]
      },
      "September04" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 22"}],
        mp2: [%{style: "req", read: "Titus 2"}],
        mpp: [{8, 1, 999}, {11, 1, 999}],
        ep1: [%{style: "req", read: "Mic 2"}],
        ep2: [%{style: "req", read: "Matt 6:1-18"}],
        epp: [{15, 1, 999}, {16, 1, 999}]
      },
      "September05" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 23"}],
        mp2: [%{style: "req", read: "Titus 3"}],
        mpp: [{12, 1, 999}, {13, 1, 999}, {14, 1, 999}],
        ep1: [%{style: "req", read: "Mic 3"}],
        ep2: [%{style: "req", read: "Matt 6:19-end"}],
        epp: [{17, 1, 999}]
      },
      "September06" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Sam 24"}],
        mp2: [%{style: "req", read: "2 Tim 1"}],
        mpp: [{18, 1, 20}],
        ep1: [%{style: "req", read: "Mic 4"}],
        ep2: [%{style: "req", read: "Matt 7"}],
        epp: [{18, 21, 50}]
      },
      "September07" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 1"}],
        mp2: [%{style: "req", read: "2 Tim 2"}],
        mpp: [{20, 1, 999}, {21, 1, 999}],
        ep1: [%{style: "req", read: "Mic 5"}],
        ep2: [%{style: "req", read: "Matt 8:1-17"}],
        epp: [{22, 1, 999}]
      },
      "September08" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Chron 22"}],
        mp2: [%{style: "req", read: "2 Tim 3"}],
        mpp: [{19, 1, 999}, {23, 1, 999}],
        ep1: [%{style: "req", read: "Mic 6"}],
        ep2: [%{style: "req", read: "Matt 8:18-end"}],
        epp: [{25, 1, 999}]
      },
      "September09" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Chron 28"}],
        mp2: [%{style: "req", read: "2 Tim 4"}],
        mpp: [{24, 1, 999}, {26, 1, 999}],
        ep1: [%{style: "req", read: "Mic 7"}],
        ep2: [%{style: "req", read: "Matt 9:1-17"}],
        epp: [{27, 1, 999}]
      },
      "September10" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 2"}],
        mp2: [%{style: "req", read: "Heb 1"}],
        mpp: [{28, 1, 999}, {29, 1, 999}],
        ep1: [%{style: "req", read: "Nahum 1"}],
        ep2: [%{style: "req", read: "Matt 9:18-34"}],
        epp: [{31, 1, 99}]
      },
      "September11" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 3"}],
        mp2: [%{style: "req", read: "Heb 2"}],
        mpp: [{30, 1, 999}, {32, 1, 999}],
        ep1: [%{style: "req", read: "Nahum 2"}],
        ep2: [%{style: "req", read: "Matt 9:35-end, 10:1-23"}],
        epp: [{33, 1, 999}]
      },
      "September12" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 4"}],
        mp2: [%{style: "req", read: "Heb 3"}],
        mpp: [{34, 1, 999}],
        ep1: [%{style: "req", read: "Nahum 3"}],
        ep2: [%{style: "req", read: "Matt 10:24-end"}],
        epp: [{35, 1, 999}]
      },
      "September13" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 5"}],
        mp2: [%{style: "req", read: "Heb 4:1-13"}],
        mpp: [{36, 1, 999}],
        ep1: [%{style: "req", read: "Hab 1"}],
        ep2: [%{style: "req", read: "Matt 11"}],
        epp: [{38, 1, 999}]
      },
      "September14" => %{
        title: "Holy Cross",
        mp1: [%{style: "req", read: "Heb 4:14-end, 5:1-10"}],
        mp2: [%{style: "req", read: "John 12:23-33"}],
        mpp: [{37, 1, 18}],
        ep1: [%{style: "req", read: "Hab 2"}],
        ep2: [%{style: "req", read: "Matt 12:1-21"}],
        epp: [{37, 19, 42}]
      },
      "September15" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 6"}],
        mp2: [%{style: "req", read: "Heb 5:11-end, 6:1-end"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "Hab 3"}],
        ep2: [%{style: "req", read: "Matt 12:22-end"}],
        epp: [{39, 1, 999}, {41, 1, 999}]
      },
      "September16" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 7"}],
        mp2: [%{style: "req", read: "Heb 7"}],
        mpp: [{42, 1, 999}, {43, 1, 999}],
        ep1: [%{style: "req", read: "Zeph 1"}],
        ep2: [%{style: "req", read: "Matt 13:1-23"}],
        epp: [{44, 1, 999}]
      },
      "September17" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 8"}],
        mp2: [%{style: "req", read: "Heb 8"}],
        mpp: [{45, 1, 999}],
        ep1: [%{style: "req", read: "Zeph 2"}],
        ep2: [%{style: "req", read: "Matt 13:24-43"}],
        epp: [{46, 1, 999}]
      },
      "September18" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 9"}],
        mp2: [%{style: "req", read: "Heb 9:1-14"}],
        mpp: [{47, 1, 999}, {48, 1, 999}],
        ep1: [%{style: "req", read: "Zeph 3"}],
        ep2: [%{style: "req", read: "Matt 13:44-end"}],
        epp: [{49, 1, 999}]
      },
      "September19" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 10"}],
        mp2: [%{style: "req", read: "Heb 9:15-end"}],
        mpp: [{50, 1, 999}],
        ep1: [%{style: "req", read: "Hag 1"}],
        ep2: [%{style: "req", read: "Matt 14"}],
        epp: [{51, 1, 999}]
      },
      "September20" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 11"}],
        mp2: [%{style: "req", read: "Heb 10:1-18"}],
        mpp: [{52, 1, 999}, {53, 1, 999}, {54, 1, 999}],
        ep1: [%{style: "req", read: "Hag 2"}],
        ep2: [%{style: "req", read: "Matt 15:1-28"}],
        epp: [{55, 1, 999}]
      },
      "September21" => %{
        title: "Matthew",
        mp1: [%{style: "req", read: "Heb 10:19-end"}],
        mp2: [%{style: "req", read: "Matt 9:9-13"}],
        mpp: [{56, 1, 999}, {57, 1, 999}],
        ep1: [%{style: "req", read: "Zech 1"}],
        ep2: [%{style: "req", read: "Matt 15:29-end, 16:1-12"}],
        epp: [{58, 1, 999}, {60, 1, 999}]
      },
      "September22" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 12"}],
        mp2: [%{style: "req", read: "Heb 11"}],
        mpp: [{59, 1, 999}],
        ep1: [%{style: "req", read: "Zech 2"}],
        ep2: [%{style: "req", read: "Matt 16:13-end"}],
        epp: [{63, 1, 999}, {64, 1, 999}]
      },
      "September23" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 13"}],
        mp2: [%{style: "req", read: "Heb 12:1-17"}],
        mpp: [{61, 1, 999}, {62, 1, 999}],
        ep1: [%{style: "req", read: "Zech 3"}],
        ep2: [%{style: "req", read: "Matt 17:1-23"}],
        epp: [{65, 1, 999}, {67, 1, 999}]
      },
      "September24" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 14"}],
        mp2: [%{style: "req", read: "Heb 12:18-end"}],
        mpp: [{68, 1, 18}],
        ep1: [%{style: "req", read: "Zech 4"}],
        ep2: [%{style: "req", read: "Matt 17:24-end, 18:1-14"}],
        epp: [{68, 19, 36}]
      },
      "September25" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 12"}],
        mp2: [%{style: "req", read: "Heb 13"}],
        mpp: [{69, 1, 19}],
        ep1: [%{style: "req", read: "Zech 5"}],
        ep2: [%{style: "req", read: "Matt 18:15-end"}],
        epp: [{69, 20, 38}]
      },
      "September26" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 13"}],
        mp2: [%{style: "req", read: "Jas 1"}],
        mpp: [{66, 1, 999}],
        ep1: [%{style: "req", read: "Zech 6"}],
        ep2: [%{style: "req", read: "Matt 19:1-15"}],
        epp: [{70, 1, 999}, {72, 1, 999}]
      },
      "September27" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 14"}],
        mp2: [%{style: "req", read: "Jas 2:1-13"}],
        mpp: [{71, 1, 999}],
        ep1: [%{style: "req", read: "Zech 7"}],
        ep2: [%{style: "req", read: "Matt 19:16-20:16"}],
        epp: [{73, 1, 999}]
      },
      "September28" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 15"}],
        mp2: [%{style: "req", read: "Jas 2:14-end"}],
        mpp: [{74, 1, 999}],
        ep1: [%{style: "req", read: "Zech 8"}],
        ep2: [%{style: "req", read: "Matt 20:17-end"}],
        epp: [{75, 1, 999}, {76, 1, 999}]
      },
      "September29" => %{
        title: "Michael",
        mp1: [%{style: "req", read: "Rev 12:7-12"}],
        mp2: [%{style: "req", read: "Jas 3"}],
        mpp: [{77, 1, 999}],
        ep1: [%{style: "req", read: "Zech 9"}],
        ep2: [%{style: "req", read: "Matt 21:1-22"}],
        epp: [{79, 1, 999}, {82, 1, 999}]
      },
      "September30" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 16"}],
        mp2: [%{style: "req", read: "Jas 4"}],
        mpp: [{78, 1, 17}],
        ep1: [%{style: "req", read: "Zech 10"}],
        ep2: [%{style: "req", read: "Matt 21:23-end"}],
        epp: [{78, 18, 39}]
      },
      "October01" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 15"}],
        mp2: [%{style: "req", read: "Jas 5"}],
        mpp: [{78, 41, 73}],
        ep1: [%{style: "req", read: "Zech 11"}],
        ep2: [%{style: "req", read: "Matt 22:1-33"}],
        epp: [{80, 1, 999}]
      },
      "October02" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 16"}],
        mp2: [%{style: "req", read: "1 Pet 1:1-21"}],
        mpp: [{81, 1, 999}],
        ep1: [%{style: "req", read: "Zech 12"}],
        ep2: [%{style: "req", read: "Matt 22:34-23:12"}],
        epp: [{83, 1, 999}]
      },
      "October03" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 17"}],
        mp2: [%{style: "req", read: "1 Pet 1:22-end, 2:1-10"}],
        mpp: [{84, 1, 999}],
        ep1: [%{style: "req", read: "Zech 13"}],
        ep2: [%{style: "req", read: "Matt 23:13-end"}],
        epp: [{85, 1, 999}]
      },
      "October04" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 18"}],
        mp2: [%{style: "req", read: "1 Pet 2:11-end, 3:1-7"}],
        mpp: [{86, 1, 999}, {87, 1, 999}],
        ep1: [%{style: "req", read: "Zech 14"}],
        ep2: [%{style: "req", read: "Matt 24:1-28"}],
        epp: [{88, 1, 999}]
      },
      "October05" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 19"}],
        mp2: [%{style: "req", read: "1 Pet 3:8-end, 4:1-6"}],
        mpp: [{89, 1, 18}],
        ep1: [%{style: "req", read: "Mal 1"}],
        ep2: [%{style: "req", read: "Matt 24:29-end"}],
        epp: [{89, 19, 52}]
      },
      "October06" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 20"}],
        mp2: [%{style: "req", read: "1 Pet 4:7-end"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Mal 2"}],
        ep2: [%{style: "req", read: "Matt 25:1-30"}],
        epp: [{91, 1, 999}]
      },
      "October07" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 21"}],
        mp2: [%{style: "req", read: "1 Pet 5"}],
        mpp: [{92, 1, 999}, {93, 1, 999}],
        ep1: [%{style: "req", read: "Mal 3"}],
        ep2: [%{style: "req", read: "Matt 25:31-end"}],
        epp: [{94, 1, 999}]
      },
      "October08" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 22"}],
        mp2: [%{style: "req", read: "2 Pet 1"}],
        mpp: [{95, 1, 999}, {96, 1, 999}],
        ep1: [%{style: "req", read: "Mal 4"}],
        ep2: [%{style: "req", read: "Matt 26:1-30"}],
        epp: [{97, 1, 999}, {98, 1, 999}]
      },
      "October09" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 20"}],
        mp2: [%{style: "req", read: "2 Pet 2"}],
        mpp: [{99, 1, 999}, {100, 1, 999}, {101, 1, 999}],
        ep1: [%{style: "req", read: "1 Maccabees 1"}],
        ep2: [%{style: "req", read: "Matt 26:31-56"}],
        epp: [{102, 1, 999}]
      },
      "October10" => %{
        title: "",
        mp1: [%{style: "req", read: "1 Kings 25"}],
        mp2: [%{style: "req", read: "2 Pet 3"}],
        mpp: [{103, 1, 999}],
        ep1: [%{style: "req", read: "2 Maccabees 6"}],
        ep2: [%{style: "req", read: "Matt 26:57-end"}],
        epp: [{104, 1, 999}]
      },
      "October11" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 20"}],
        mp2: [%{style: "req", read: "Jude"}],
        mpp: [{105, 1, 22}],
        ep1: [%{style: "req", read: "2 Maccabees 7"}],
        ep2: [%{style: "req", read: "Matt 27:1-26"}],
        epp: [{105, 23, 45}]
      },
      "October12" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 1"}],
        mp2: [%{style: "req", read: "1 John 1:1-end, 2:1-6"}],
        mpp: [{106, 1, 18}],
        ep1: [%{style: "req", read: "2 Maccabees 8"}],
        ep2: [%{style: "req", read: "Matt 27:27-56"}],
        epp: [{106, 19, 48}]
      },
      "October13" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 2"}],
        mp2: [%{style: "req", read: "1 John 2:7-end"}],
        mpp: [{107, 1, 22}],
        ep1: [%{style: "req", read: "2 Maccabees 9"}],
        ep2: [%{style: "req", read: "Matt 27:57-end, 28:1-end"}],
        epp: [{107, 23, 43}]
      },
      "October14" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 3"}],
        mp2: [%{style: "req", read: "1 John 3:1-10"}],
        mpp: [{108, 1, 999}, {110, 1, 999}],
        ep1: [%{style: "req", read: "2 Maccabees 10"}],
        ep2: [%{style: "req", read: "Mark 1:1-13"}],
        epp: [{109, 1, 999}]
      },
      "October15" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 4"}],
        mp2: [%{style: "req", read: "1 John 3:11-end, 4:1-6"}],
        mpp: [{111, 1, 999}, {112, 1, 999}],
        ep1: [%{style: "req", read: "1 Maccabees 7"}],
        ep2: [%{style: "req", read: "Mark 1:14-31"}],
        epp: [{113, 1, 999}, {114, 1, 999}]
      },
      "October16" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 5"}],
        mp2: [%{style: "req", read: "1 John 4:7-end"}],
        mpp: [{115, 1, 999}],
        ep1: [%{style: "req", read: "1 Maccabees 9"}],
        ep2: [%{style: "req", read: "Mark 1:32-end"}],
        epp: [{116, 1, 999}, {117, 1, 999}]
      },
      "October17" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 6"}],
        mp2: [%{style: "req", read: "1 John 5"}],
        mpp: [{119, 1, 24}],
        ep1: [%{style: "req", read: "1 Maccabees 13"}],
        ep2: [%{style: "req", read: "Mark 2:1-22"}],
        epp: [{119, 25, 48}]
      },
      "October18" => %{
        title: "Luke",
        mp1: [%{style: "req", read: "2 John"}],
        mp2: [%{style: "req", read: "Luke 1:1-4"}],
        mpp: [{119, 49, 72}],
        ep1: [%{style: "req", read: "1 Maccabees 14"}],
        ep2: [%{style: "req", read: "Mark 2:23-end, 3:1-12"}],
        epp: [{119, 73, 88}]
      },
      "October19" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 7"}],
        mp2: [%{style: "req", read: "3 John"}],
        mpp: [{119, 89, 104}],
        ep1: [%{style: "req", read: "Isa 1"}],
        ep2: [%{style: "req", read: "Mark 3:13-end"}],
        epp: [{119, 105, 128}]
      },
      "October20" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 8"}],
        mp2: [%{style: "req", read: "Acts 1:1-14"}],
        mpp: [{119, 129, 152}],
        ep1: [%{style: "req", read: "Isa 2"}],
        ep2: [%{style: "req", read: "Mark 4:1-34"}],
        epp: [{119, 153, 176}]
      },
      "October21" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 9"}],
        mp2: [%{style: "req", read: "Acts 1:15-end"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Isa 3"}],
        ep2: [%{style: "req", read: "Mark 4:35-end, 5:1-20"}],
        epp: [{120, 1, 999}, {121, 1, 999}]
      },
      "October22" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 10"}],
        mp2: [%{style: "req", read: "Acts 2:1-21"}],
        mpp: [{122, 1, 999}, {123, 1, 999}],
        ep1: [%{style: "req", read: "Isa 4"}],
        ep2: [%{style: "req", read: "Mark 5:21-end"}],
        epp: [{124, 1, 999}, {125, 1, 999}, {126, 1, 999}]
      },
      "October23" => %{
        title: "James Jer.",
        mp1: [%{style: "req", read: "Acts 21:17-26"}],
        mp2: [%{style: "req", read: "Acts 2:22-end"}],
        mpp: [{127, 1, 999}, {128, 1, 999}],
        ep1: [%{style: "req", read: "Isa 5"}],
        ep2: [%{style: "req", read: "Mark 6:1-29"}],
        epp: [{129, 1, 999}, {130, 1, 999}, {131, 1, 999}]
      },
      "October24" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 11"}],
        mp2: [%{style: "req", read: "Acts 3:1-end, 4:1-4"}],
        mpp: [{132, 1, 999}, {133, 1, 999}],
        ep1: [%{style: "req", read: "Isa 6"}],
        ep2: [%{style: "req", read: "Mark 6:30-end"}],
        epp: [{134, 1, 999}, {135, 1, 999}]
      },
      "October25" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 12"}],
        mp2: [%{style: "req", read: "Acts 4:5-31"}],
        mpp: [{136, 1, 999}],
        ep1: [%{style: "req", read: "Isa 7"}],
        ep2: [%{style: "req", read: "Mark 7:1-23"}],
        epp: [{137, 1, 999}, {138, 1, 999}]
      },
      "October26" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 13"}],
        mp2: [%{style: "req", read: "Acts 4:32-end, 5:1-11"}],
        mpp: [{139, 1, 999}],
        ep1: [%{style: "req", read: "Isa 8"}],
        ep2: [%{style: "req", read: "Mark 7:24-end, 8:1-10"}],
        epp: [{141, 1, 999}, {142, 1, 999}]
      },
      "October27" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 14"}],
        mp2: [%{style: "req", read: "Acts 5:12-end"}],
        mpp: [{140, 1, 999}],
        ep1: [%{style: "req", read: "Isa 9"}],
        ep2: [%{style: "req", read: "Mark 8:11-end"}],
        epp: [{143, 1, 999}]
      },
      "October28" => %{
        title: "Sts. Simon And Jude",
        mp1: [%{style: "req", read: "Acts 6:1-end, 7:1-16"}],
        mp2: [%{style: "req", read: "John 14:15-31"}],
        mpp: [{144, 1, 999}],
        ep1: [%{style: "req", read: "Isa 10"}],
        ep2: [%{style: "req", read: "Mark 9:1-29"}],
        epp: [{145, 1, 999}]
      },
      "October29" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 26 "}],
        mp2: [%{style: "req", read: "Acts 7:17-34"}],
        mpp: [{146, 1, 999}],
        ep1: [%{style: "req", read: "Isa 11"}],
        ep2: [%{style: "req", read: "Mark 9:30-end"}],
        epp: [{147, 1, 999}]
      },
      "October30" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 15"}],
        mp2: [%{style: "req", read: "Acts 7:35-end, 8:1-3"}],
        mpp: [{148, 1, 999}],
        ep1: [%{style: "req", read: "Isa 12"}],
        ep2: [%{style: "req", read: "Mark 10:1-31"}],
        epp: [{149, 1, 999}, {150, 1, 999}]
      },
      "October31" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 16"}],
        mp2: [%{style: "req", read: "Acts 8:4-25"}],
        mpp: [{2, 1, 999}],
        ep1: [%{style: "req", read: "Isa 13"}],
        ep2: [%{style: "req", read: "Mark 10:32-end"}],
        epp: [{3, 1, 999}, {4, 1, 999}]
      },
      "November01" => %{
        title: "All Saints",
        mp1: [%{style: "req", read: "Heb 11:32-end, 12:1-2"}],
        mp2: [%{style: "req", read: "Acts 8:26-end"}],
        mpp: [{1, 1, 999}, {15, 1, 999}],
        ep1: [%{style: "req", read: "Isa 14"}],
        ep2: [%{style: "req", read: "Rev 19:1-16"}],
        epp: [{34, 1, 999}]
      },
      "November02" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 17"}],
        mp2: [%{style: "req", read: "Acts 9:1-31"}],
        mpp: [{5, 1, 999}, {6, 1, 999}],
        ep1: [%{style: "req", read: "Isa 15"}],
        ep2: [%{style: "req", read: "Mark 11:1-26"}],
        epp: [{7, 1, 999}]
      },
      "November03" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 28"}],
        mp2: [%{style: "req", read: "Acts 9:32-end"}],
        mpp: [{9, 1, 999}],
        ep1: [%{style: "req", read: "Isa 16"}],
        ep2: [%{style: "req", read: "Mark 11:27-end, 12:1-12"}],
        epp: [{10, 1, 999}]
      },
      "November04" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 29"}],
        mp2: [%{style: "req", read: "Acts 10:1-23"}],
        mpp: [{8, 1, 999}, {11, 1, 999}],
        ep1: [%{style: "req", read: "Isa 17"}],
        ep2: [%{style: "req", read: "Mark 12:13-34"}],
        epp: [{15, 1, 999}, {16, 1, 999}]
      },
      "November05" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 30"}],
        mp2: [%{style: "req", read: "Acts 10:24-end"}],
        mpp: [{12, 1, 999}, {13, 1, 999}, {14, 1, 999}],
        ep1: [%{style: "req", read: "Isa 18"}],
        ep2: [%{style: "req", read: "Mark 12:35-end, 13:1-13"}],
        epp: [{17, 1, 999}]
      },
      "November06" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 20"}],
        mp2: [%{style: "req", read: "Acts 11:1-18"}],
        mpp: [{18, 1, 20}],
        ep1: [%{style: "req", read: "Isa 19"}],
        ep2: [%{style: "req", read: "Mark 13:14-end"}],
        epp: [{18, 21, 50}]
      },
      "November07" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Chron 33"}],
        mp2: [%{style: "req", read: "Acts 11:19-end"}],
        mpp: [{20, 1, 999}, {21, 1, 999}],
        ep1: [%{style: "req", read: "Isa 20"}],
        ep2: [%{style: "req", read: "Mark 14:1-25"}],
        epp: [{22, 1, 999}]
      },
      "November08" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 21"}],
        mp2: [%{style: "req", read: "Acts 12:1-24"}],
        mpp: [{19, 1, 999}, {23, 1, 999}],
        ep1: [%{style: "req", read: "Isa 21"}],
        ep2: [%{style: "req", read: "Mark 14:26-52"}],
        epp: [{25, 1, 999}]
      },
      "November09" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 22"}],
        mp2: [%{style: "req", read: "Acts 12:25-end, 13:1-12"}],
        mpp: [{24, 1, 999}, {26, 1, 999}],
        ep1: [%{style: "req", read: "Isa 22"}],
        ep2: [%{style: "req", read: "Mark 14:53-end"}],
        epp: [{27, 1, 999}]
      },
      "November10" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 23"}],
        mp2: [%{style: "req", read: "Acts 13:13-43"}],
        mpp: [{28, 1, 999}, {29, 1, 999}],
        ep1: [%{style: "req", read: "Isa 23"}],
        ep2: [%{style: "req", read: "Mark 15"}],
        epp: [{31, 1, 999}]
      },
      "November11" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 24"}],
        mp2: [%{style: "req", read: "Acts 13:44-end, 14:1-7"}],
        mpp: [{30, 1, 999}, {32, 1, 999}],
        ep1: [%{style: "req", read: "Isa 24"}],
        ep2: [%{style: "req", read: "Mark 16"}],
        epp: [{33, 1, 999}]
      },
      "November12" => %{
        title: "",
        mp1: [%{style: "req", read: "2 Kings 25"}],
        mp2: [%{style: "req", read: "Acts 14:8-end"}],
        mpp: [{34, 1, 999}],
        ep1: [%{style: "req", read: "Isa 25"}],
        ep2: [%{style: "req", read: "Luke 1:1-23"}],
        epp: [{35, 1, 999}]
      },
      "November13" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 4"}],
        mp2: [%{style: "req", read: "Acts 15:1-21"}],
        mpp: [{36, 1, 999}],
        ep1: [%{style: "req", read: "Isa 26"}],
        ep2: [%{style: "req", read: "Luke 1:24-56"}],
        epp: [{38, 1, 999}]
      },
      "November14" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 8"}],
        mp2: [%{style: "req", read: "Acts 15:22-35"}],
        mpp: [{37, 1, 18}],
        ep1: [%{style: "req", read: "Isa 27"}],
        ep2: [%{style: "req", read: "Luke 1:57-end"}],
        epp: [{37, 19, 42}]
      },
      "November15" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 9"}],
        mp2: [%{style: "req", read: "Acts 15:36-end, 16:1-5"}],
        mpp: [{40, 1, 999}],
        ep1: [%{style: "req", read: "Isa 28"}],
        ep2: [%{style: "req", read: "Luke 2:1-21"}],
        epp: [{39, 1, 999}, {41, 1, 999}]
      },
      "November16" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 10"}],
        mp2: [%{style: "req", read: "Acts 16:6-end"}],
        mpp: [{42, 1, 999}, {43, 1, 999}],
        ep1: [%{style: "req", read: "Isa 29"}],
        ep2: [%{style: "req", read: "Luke 2:22-end"}],
        epp: [{44, 1, 999}]
      },
      "November17" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 11"}],
        mp2: [%{style: "req", read: "Acts 17:1-15"}],
        mpp: [{45, 1, 999}],
        ep1: [%{style: "req", read: "Isa 30"}],
        ep2: [%{style: "req", read: "Luke 3:1-22"}],
        epp: [{46, 1, 999}]
      },
      "November18" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 12"}],
        mp2: [%{style: "req", read: "Acts 17:16-end"}],
        mpp: [{47, 1, 999}, {48, 1, 999}],
        ep1: [%{style: "req", read: "Isa 31"}],
        ep2: [%{style: "req", read: "Luke 3:23-end"}],
        epp: [{49, 1, 999}]
      },
      "November19" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 13"}],
        mp2: [%{style: "req", read: "Acts 18:1-23"}],
        mpp: [{50, 1, 999}],
        ep1: [%{style: "req", read: "Isa 32"}],
        ep2: [%{style: "req", read: "Luke 4:1-30"}],
        epp: [{51, 1, 999}]
      },
      "November20" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 14"}],
        mp2: [%{style: "req", read: "Acts 18:24-end, 19:1-7"}],
        mpp: [{52, 1, 999}, {53, 1, 999}, {54, 1, 999}],
        ep1: [%{style: "req", read: "Isa 33"}],
        ep2: [%{style: "req", read: "Luke 4:31-end"}],
        epp: [{55, 1, 999}]
      },
      "November21" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 15"}],
        mp2: [%{style: "req", read: "Acts 19:8-20"}],
        mpp: [{56, 1, 999}, {57, 1, 999}],
        ep1: [%{style: "req", read: "Isa 34"}],
        ep2: [%{style: "req", read: "Luke 5:1-16"}],
        epp: [{58, 1, 999}, {60, 1, 999}]
      },
      "November22" => %{
        title: "",
        mp1: [%{style: "req", read: "Judith 16"}],
        mp2: [%{style: "req", read: "Acts 19:21-end"}],
        mpp: [{59, 1, 999}],
        ep1: [%{style: "req", read: "Isa 35"}],
        ep2: [%{style: "req", read: "Luke 5:17-end"}],
        epp: [{63, 1, 999}, {64, 1, 999}]
      },
      "November23" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 1"}],
        mp2: [%{style: "req", read: "Acts 20:1-16"}],
        mpp: [{61, 1, 999}, {62, 1, 999}],
        ep1: [%{style: "req", read: "Isa 36"}],
        ep2: [%{style: "req", read: "Luke 6:1-19"}],
        epp: [{65, 1, 999}, {67, 1, 999}]
      },
      "November24" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 2"}],
        mp2: [%{style: "req", read: "Acts 20:17-end"}],
        mpp: [{68, 1, 18}],
        ep1: [%{style: "req", read: "Isa 37"}],
        ep2: [%{style: "req", read: "Luke 6:20-38"}],
        epp: [{68, 19, 36}]
      },
      "November25" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 4"}],
        mp2: [%{style: "req", read: "Acts 21:1-16"}],
        mpp: [{69, 1, 19}],
        ep1: [%{style: "req", read: "Isa 38"}],
        ep2: [%{style: "req", read: "Luke 6:39-end, 7:1-10"}],
        epp: [{69, 20, 38}]
      },
      "November26" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 6"}],
        mp2: [%{style: "req", read: "Acts 21:17-36"}],
        mpp: [{66, 1, 999}],
        ep1: [%{style: "req", read: "Isa 39"}],
        ep2: [%{style: "req", read: "Luke 7:11-35"}],
        epp: [{70, 1, 999}, {72, 1, 999}]
      },
      "November27" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 7"}],
        mp2: [%{style: "req", read: "Acts 21:37-end, 22:1-22"}],
        mpp: [{71, 1, 999}],
        ep1: [%{style: "req", read: "Isa 40"}],
        ep2: [%{style: "req", read: "Luke 7:36-end"}],
        epp: [{73, 1, 999}]
      },
      "November28" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 9"}],
        mp2: [%{style: "req", read: "Acts 22:23-end, 23:1-11"}],
        mpp: [{74, 1, 999}],
        ep1: [%{style: "req", read: "Isa 41"}],
        ep2: [%{style: "req", read: "Luke 8:1-21"}],
        epp: [{75, 1, 999}, {76, 1, 999}]
      },
      "November29" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 10"}],
        mp2: [%{style: "req", read: "Acts 23:12-end"}],
        mpp: [{77, 1, 999}],
        ep1: [%{style: "req", read: "Isa 42"}],
        ep2: [%{style: "req", read: "Luke 8:22-end"}],
        epp: [{79, 1, 999}, {82, 1, 999}]
      },
      "November30" => %{
        title: "Andrew",
        mp1: [%{style: "req", read: "Ecclesiasticus 11"}],
        mp2: [%{style: "req", read: "John 1:35-42"}],
        mpp: [{78, 1, 17}],
        ep1: [%{style: "req", read: "Isa 43"}],
        ep2: [%{style: "req", read: "Luke 9:1-17"}],
        epp: [{78, 18, 39}]
      },
      "December01" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 14"}],
        mp2: [%{style: "req", read: "Acts 24:1-23"}],
        mpp: [{78, 41, 73}],
        ep1: [%{style: "req", read: "Isa 44"}],
        ep2: [%{style: "req", read: "Luke 9:18-50"}],
        epp: [{80, 1, 999}]
      },
      "December02" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 17"}],
        mp2: [%{style: "req", read: "Acts 24:24-end, 25:1-12"}],
        mpp: [{81, 1, 999}],
        ep1: [%{style: "req", read: "Isa 45"}],
        ep2: [%{style: "req", read: "Luke 9:51-end"}],
        epp: [{83, 1, 999}]
      },
      "December03" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 18"}],
        mp2: [%{style: "req", read: "Acts 25:13-end"}],
        mpp: [{84, 1, 999}],
        ep1: [%{style: "req", read: "Isa 46"}],
        ep2: [%{style: "req", read: "Luke 10:1-24"}],
        epp: [{85, 1, 999}]
      },
      "December04" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 21"}],
        mp2: [%{style: "req", read: "Acts 26"}],
        mpp: [{86, 1, 999}, {87, 1, 999}],
        ep1: [%{style: "req", read: "Isa 47"}],
        ep2: [%{style: "req", read: "Luke 10:25-end"}],
        epp: [{88, 1, 999}]
      },
      "December05" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 34"}],
        mp2: [%{style: "req", read: "Acts 27"}],
        mpp: [{89, 1, 18}],
        ep1: [%{style: "req", read: "Isa 48"}],
        ep2: [%{style: "req", read: "Luke 11:1-28"}],
        epp: [{89, 19, 52}]
      },
      "December06" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 38"}],
        mp2: [%{style: "req", read: "Acts 28:1-15"}],
        mpp: [{90, 1, 999}],
        ep1: [%{style: "req", read: "Isa 49"}],
        ep2: [%{style: "req", read: "Luke 11:29-end"}],
        epp: [{91, 1, 999}]
      },
      "December07" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 39"}],
        mp2: [%{style: "req", read: "Acts 28:16-end"}],
        mpp: [{92, 1, 999}, {93, 1, 999}],
        ep1: [%{style: "req", read: "Isa 50"}],
        ep2: [%{style: "req", read: "Luke 12:1-34"}],
        epp: [{94, 1, 999}]
      },
      "December08" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 44"}],
        mp2: [%{style: "req", read: "Rev 1"}],
        mpp: [{95, 1, 999}, {96, 1, 999}],
        ep1: [%{style: "req", read: "Isa 51"}],
        ep2: [%{style: "req", read: "Luke 12:35-53"}],
        epp: [{97, 1, 999}, {98, 1, 999}]
      },
      "December09" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 45"}],
        mp2: [%{style: "req", read: "Rev 2:1-17"}],
        mpp: [{99, 1, 999}, {100, 1, 999}, {101, 1, 999}],
        ep1: [%{style: "req", read: "Isa 52"}],
        ep2: [%{style: "req", read: "Luke 12:54-end, 13:1-9"}],
        epp: [{102, 1, 999}]
      },
      "December10" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 46"}],
        mp2: [%{style: "req", read: "Rev 2:18-end, 3:1-6"}],
        mpp: [{103, 1, 999}],
        ep1: [%{style: "req", read: "Isa 53"}],
        ep2: [%{style: "req", read: "Luke 13:10-end"}],
        epp: [{104, 1, 999}]
      },
      "December11" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 47"}],
        mp2: [%{style: "req", read: "Rev 3:7-end"}],
        mpp: [{105, 1, 22}],
        ep1: [%{style: "req", read: "Isa 54"}],
        ep2: [%{style: "req", read: "Luke 14:1-24"}],
        epp: [{105, 23, 45}]
      },
      "December12" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 48"}],
        mp2: [%{style: "req", read: "Rev 4"}],
        mpp: [{106, 1, 18}],
        ep1: [%{style: "req", read: "Isa 55"}],
        ep2: [%{style: "req", read: "Luke 14:25-end, 15:1-10"}],
        epp: [{106, 19, 48}]
      },
      "December13" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 49"}],
        mp2: [%{style: "req", read: "Rev 5"}],
        mpp: [{107, 1, 22}],
        ep1: [%{style: "req", read: "Isa 56"}],
        ep2: [%{style: "req", read: "Luke 15:11-end"}],
        epp: [{107, 23, 43}]
      },
      "December14" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 50"}],
        mp2: [%{style: "req", read: "Rev 6"}],
        mpp: [{108, 1, 999}, {110, 1, 999}],
        ep1: [%{style: "req", read: "Isa 57"}],
        ep2: [%{style: "req", read: "Luke 16"}],
        epp: [{109, 1, 999}]
      },
      "December15" => %{
        title: "",
        mp1: [%{style: "req", read: "Ecclesiasticus 51"}],
        mp2: [%{style: "req", read: "Rev 7"}],
        mpp: [{111, 1, 999}, {112, 1, 999}],
        ep1: [%{style: "req", read: "Isa 58"}],
        ep2: [%{style: "req", read: "Luke 17:1-19"}],
        epp: [{113, 1, 999}, {114, 1, 999}]
      },
      "December16" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 1"}],
        mp2: [%{style: "req", read: "Rev 8"}],
        mpp: [{115, 1, 999}],
        ep1: [%{style: "req", read: "Isa 59"}],
        ep2: [%{style: "req", read: "Luke 17:20-end"}],
        epp: [{116, 1, 999}, {117, 1, 999}]
      },
      "December17" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 2"}],
        mp2: [%{style: "req", read: "Rev 9"}],
        mpp: [{119, 1, 24}],
        ep1: [%{style: "req", read: "Isa 60"}],
        ep2: [%{style: "req", read: "Luke 18:1-30"}],
        epp: [{119, 25, 48}]
      },
      "December18" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 3"}],
        mp2: [%{style: "req", read: "Rev 10"}],
        mpp: [{119, 49, 72}],
        ep1: [%{style: "req", read: "Isa 61"}],
        ep2: [%{style: "req", read: "Luke 18:31-end, 19:1-10"}],
        epp: [{119, 73, 88}]
      },
      "December19" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 4"}],
        mp2: [%{style: "req", read: "Rev 11"}],
        mpp: [{119, 89, 104}],
        ep1: [%{style: "req", read: "Isa 62"}],
        ep2: [%{style: "req", read: "Luke 19:11-28"}],
        epp: [{119, 105, 128}]
      },
      "December20" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 5"}],
        mp2: [%{style: "req", read: "Rev 12"}],
        mpp: [{119, 129, 152}],
        ep1: [%{style: "req", read: "Isa 63"}],
        ep2: [%{style: "req", read: "Luke 19:29-end"}],
        epp: [{119, 153, 176}]
      },
      "December21" => %{
        title: "Thomas",
        mp1: [%{style: "req", read: "Rev 13 "}],
        mp2: [%{style: "req", read: "John 14:1-7"}],
        mpp: [{118, 1, 999}],
        ep1: [%{style: "req", read: "Isa 64"}],
        ep2: [%{style: "req", read: "Luke 20:1-26"}],
        epp: [{120, 1, 999}, {121, 1, 999}]
      },
      "December22" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 6"}],
        mp2: [%{style: "req", read: "Rev 14"}],
        mpp: [{122, 1, 999}, {123, 1, 999}],
        ep1: [%{style: "req", read: "Isa 65"}],
        ep2: [%{style: "req", read: "Luke 20:27-end, 21:1-4"}],
        epp: [{124, 1, 999}, {125, 1, 999}, {126, 1, 999}]
      },
      "December23" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 7"}],
        mp2: [%{style: "req", read: "Rev 15"}],
        mpp: [{127, 1, 999}, {128, 1, 999}],
        ep1: [%{style: "req", read: "Isa 66"}],
        ep2: [%{style: "req", read: "Luke 21:5-end"}],
        epp: [{129, 1, 999}, {130, 1, 999}, {131, 1, 999}]
      },
      "December24" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 8"}],
        mp2: [%{style: "req", read: "Rev 16"}],
        mpp: [{132, 1, 999}, {133, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 1"}],
        ep2: [%{style: "req", read: "Luke 22:1-38"}],
        epp: [{134, 1, 999}, {135, 1, 999}]
      },
      "December25" => %{
        title: "Christmas",
        mp1: [%{style: "req", read: "Isa 9:1-8"}],
        mp2: [%{style: "req", read: "Rev 17"}],
        mpp: [{85, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 2"}],
        ep2: [%{style: "req", read: "Luke 2:1-14"}],
        epp: [{110, 1, 999}, {45, 1, 999}]
      },
      "December26" => %{
        title: "Stephen",
        mp1: [%{style: "req", read: "Acts 6:8-end, 7:1-6, 7:44-60"}],
        mp2: [%{style: "req", read: "Rev 18"}],
        mpp: [{136, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 3"}],
        ep2: [%{style: "req", read: "Luke 22:39-53"}],
        epp: [{137, 1, 999}, {138, 1, 999}]
      },
      "December27" => %{
        title: "John",
        mp1: [%{style: "req", read: "Rev 19"}],
        mp2: [%{style: "req", read: "John 21:9-25"}],
        mpp: [{139, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 4"}],
        ep2: [%{style: "req", read: "Luke 22:54-end"}],
        epp: [{141, 1, 999}, {142, 1, 999}]
      },
      "December28" => %{
        title: "Innocents",
        mp1: [%{style: "req", read: "Jer 31:1-17"}],
        mp2: [%{style: "req", read: "Rev 20"}],
        mpp: [{140, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 5"}],
        ep2: [%{style: "req", read: "Luke 23:1-25"}],
        epp: [{143, 1, 999}]
      },
      "December29" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 9"}],
        mp2: [%{style: "req", read: "Rev 21:1-14"}],
        mpp: [{144, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 6"}],
        ep2: [%{style: "req", read: "Luke:23:26-49"}],
        epp: [{145, 1, 999}]
      },
      "December30" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 10"}],
        mp2: [%{style: "req", read: "Rev 21:15-end, 22:1-5"}],
        mpp: [{146, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 7"}],
        ep2: [%{style: "req", read: "Luke 23:50-end, 24:1-12"}],
        epp: [{147, 1, 999}]
      },
      "December31" => %{
        title: "",
        mp1: [%{style: "req", read: "Wisdom 11"}],
        mp2: [%{style: "req", read: "Rev 22:6-end"}],
        mpp: [{148, 1, 999}],
        ep1: [%{style: "req", read: "Song of Songs 8"}],
        ep2: [%{style: "req", read: "Luke 24:13-end"}],
        epp: [{149, 1, 999}, {150, 1, 999}]
      }
    }

    # end of model
  end
end
