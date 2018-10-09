require IEx

defmodule IphodWeb.PrayerController do
  use IphodWeb, :controller
  use Timex
  import Iphod.DailyOptions, only: [get_daily_options: 2]
  import BibleText, only: [lesson_with_body: 2]
  @tz "America/Los_Angeles"

  def mp(conn, params) do
    if params["text"] |> is_nil do
      render(conn, "get_params.html", model: need_params(params, "mp"), page_controller: "prayer")
    else
      select_language(params)
      {psalm, text} = translations(params)
      model = prayer_model("mp", psalm, text)

      conn
      |> put_layout("app.html")
      |> render("mp.html", model: model, page_controller: "prayer")
    end
  end

  def mp_for(conn, params) do
    date = params["date"] |> Timex.parse!("{YYYY}-{0M}-{0D}")
    model = prayer_model("mp", "BCP", "ESV", date)

    conn
    |> put_layout("app.html")
    |> render("mp.html", model: model, page_controller: "prayer")
  end

  def midday(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("midday.html", page_controller: "prayer")
  end

  def need_params(params, office) do
    if params["psalm"] |> is_nil do
      %{psalm: "undef", text: "undef", office: office}
    else
      %{psalm: params["psalm"], text: "undef", office: office}
    end
  end

  def ep(conn, params) do
    if params["text"] |> is_nil do
      render(conn, "get_params.html", model: need_params(params, "ep"), page_controller: "prayer")
    else
      select_language(params)
      {psalm, text} = translations(params)

      conn
      |> put_layout("app.html")
      |> render("ep.html", model: prayer_model("ep", psalm, text), page_controller: "prayer")
    end
  end

  def ep_for(conn, params) do
    date = params["date"] |> Timex.parse!("{YYYY}-{0M}-{0D}")
    model = prayer_model("ep", "BCP", "ESV", date)

    conn
    |> put_layout("app.html")
    |> render("ep.html", model: model, page_controller: "prayer")
  end

  def compline(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("compline.html", page_controller: "prayer")
  end

  def family(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("family.html", page_controller: "prayer")
  end

  def reconciliation(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("reconciliation.html", page_controller: "prayer")
  end

  def timeofdeath(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("timeofdeath.html", page_controller: "prayer")
  end

  def tothesick(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("tothesick.html", page_controller: "prayer")
  end

  def communiontosick(conn, _params) do
    conn
    |> put_layout("app.html")
    |> render("communiontosick.html", page_controller: "prayer")
  end

  def office(conn, params) do
    case params["prayer"] do
      "mp" ->
        mp(conn, params)

      "ep" ->
        ep(conn, params)

      "midday" ->
        midday(conn, params)

      "compline" ->
        compline(conn, params)

      "family" ->
        family(conn, params)

      "reconciliation" ->
        reconciliation(conn, params)

      "timeofdeath" ->
        timeofdeath(conn, params)

      "tothesick" ->
        tothesick(conn, params)

      _ ->
        conn
        |> put_layout("local_office.html")
        |> render(page_controller: "prayer")
    end
  end

  def mp_cusimp(conn, _params), do: xlate(conn, "mp", "cu89s", "zh")
  def mp_cutrad(conn, _params), do: xlate(conn, "mp", "cu89t", "zh")
  def ep_cusimp(conn, _params), do: xlate(conn, "ep", "cu89s", "zh")
  def ep_cutrad(conn, _params), do: xlate(conn, "ep", "cu89t", "zh")

  def xlate(conn, mpep, ver, lang) do
    Gettext.put_locale(IphodWeb.Gettext, lang)

    conn
    |> put_layout("app.html")
    |> render("#{mpep}.html", model: prayer_model(mpep, ver, ver))
  end

  def readmp(conn, params) do
    select_language(params)
    {psalm, text} = translations(params)

    conn
    |> put_layout("readable.html")
    |> render("mp.html", model: prayer_model("mp", psalm, text))
  end

  def readep(conn, params) do
    select_language(params)
    {psalm, text} = translations(params)

    conn
    |> put_layout("readable.html")
    |> render("ep.html", model: prayer_model("ep", psalm, text))
  end

  # HELPERS ------

  def select_language(params) do
    unless params["locale"], do: Gettext.put_locale(IphodWeb.Gettext, "en")
  end

  def translations(map) do
    psalm = if map |> Map.has_key?("psalm"), do: map["psalm"], else: "Coverdale"
    text = if map |> Map.has_key?("text"), do: map["text"], else: "ESV"
    {psalm, text}
  end

  def prayer_model("mp", psalm_translation, text_translation) do
    prayer_model("mp", psalm_translation, text_translation, Timex.now(@tz))
  end

  def prayer_model("ep", psalm_translation, text_translation) do
    prayer_model("ep", psalm_translation, text_translation, Timex.now(@tz))
  end

  def prayer_model("mp", psalm_translation, text_translation, rightNow) do
    day = rightNow |> Timex.to_date()
    {season, _wk, _lityr, _date} = rightNow |> Lityear.to_season()
    day_of_week = day |> Timex.weekday() |> Timex.day_name()
    {sent, ref} = DailyReading.opening_sentence("mp", day)
    dreading = DailyReading.readings(day)
    {invitatory, collect} = get_daily_options(day, dreading)

    dreading
    |> Map.put(:opening_sentence, sent)
    |> Map.put(:opening_sentence_ref, ref)
    |> Map.put(:antiphon, DailyReading.antiphon(day))
    |> Map.put(:invitatory_canticle, invitatory)
    |> put_reading(dreading[:mpp], psalm_translation)
    |> put_reading(dreading[:mp1], text_translation)
    |> put_reading(dreading[:mp2], text_translation)
    |> Map.put(:ot_canticle, put_canticle("mp", "ot", season, day_of_week))
    |> Map.put(:nt_canticle, put_canticle("mp", "nt", season, day_of_week))
    |> Map.put(:collect_of_week, collect)
    |> Map.put(:day, day_of_week)
    |> Map.put(:reflID, reflectionID(day))
  end

  def prayer_model("ep", psalm_translation, text_translation, rightNow) do
    day = rightNow |> Timex.to_date()
    {season, _wk, _lityr, _date} = rightNow |> Lityear.to_season()
    day_of_week = day |> Timex.weekday() |> Timex.day_name()
    {sent, ref} = DailyReading.opening_sentence("ep", day)
    dreading = DailyReading.readings(day)
    {invitatory, collect} = get_daily_options(day, dreading)

    dreading
    |> Map.put(:opening_sentence, sent)
    |> Map.put(:opening_sentence_ref, ref)
    |> Map.put(:antiphon, DailyReading.antiphon(day))
    |> Map.put(:invitatory_canticle, invitatory)
    |> put_reading(dreading[:epp], psalm_translation)
    |> put_reading(dreading[:ep1], text_translation)
    |> put_reading(dreading[:ep2], text_translation)
    |> Map.put(:ot_canticle, put_canticle("ep", "ot", season, day_of_week))
    |> Map.put(:nt_canticle, put_canticle("ep", "nt", season, day_of_week))
    |> Map.put(:collect_of_week, collect)
    |> Map.put(:day, day_of_week)
    |> Map.put(:reflID, reflectionID(day))
  end

  def put_canticle("mp", "ot", season, "Sunday") when season == "advent", do: "surge_illuminare"
  def put_canticle("mp", "ot", season, "Sunday") when season == "easter", do: "cantemus_domino"
  def put_canticle("mp", "ot", season, "Friday") when season == "easter", do: "te_deum"
  def put_canticle("mp", "ot", season, "Friday") when season == "easterWeek", do: "te_deum"

  def put_canticle("mp", "ot", season, "Sunday") when season == "lent", do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season, "Monday") when season == "lent", do: "quaerite_dominum"
  def put_canticle("mp", "ot", season, "Tuesday") when season == "lent", do: "quaerite_dominum"
  def put_canticle("mp", "ot", season, "Wednesday") when season == "lent", do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season, "Thursday") when season == "lent", do: "quaerite_dominum"
  def put_canticle("mp", "ot", season, "Friday") when season == "lent", do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season, "Saturday") when season == "lent", do: "quaerite_dominum"
  def put_canticle("mp", "ot", _season, "Sunday"), do: "benedictus"
  def put_canticle("mp", "ot", _season, "Monday"), do: "ecce_deus"
  def put_canticle("mp", "ot", _season, "Tuesday"), do: "benedictis_es_domine"
  def put_canticle("mp", "ot", _season, "Wednesday"), do: "surge_illuminare"
  def put_canticle("mp", "ot", _season, "Thursday"), do: "cantemus_domino"
  def put_canticle("mp", "ot", _season, "Friday"), do: "quaerite_dominum"
  def put_canticle("mp", "ot", _season, "Saturday"), do: "benedicite_omnia_opera_domini"

  def put_canticle("mp", "nt", season, "Sunday") when season == "advent", do: "benedictus"

  def put_canticle("mp", "nt", season, "Thursday") when season == "advent",
    do: "magna_et_mirabilia"

  def put_canticle("mp", "nt", season, "Sunday") when season == "lent", do: "benedictus"
  def put_canticle("mp", "nt", season, "Thursday") when season == "lent", do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", _season, "Sunday"), do: "te_deum"
  def put_canticle("mp", "nt", _season, "Monday"), do: "benedictus"
  def put_canticle("mp", "nt", _season, "Tuesday"), do: "benedictus"
  def put_canticle("mp", "nt", _season, "Wednesday"), do: "benedictus"
  def put_canticle("mp", "nt", _season, "Thursday"), do: "benedictus"
  def put_canticle("mp", "nt", _season, "Friday"), do: "benedictus"
  def put_canticle("mp", "nt", _season, "Saturday"), do: "benedictus"

  def put_canticle("ep", "ot", season, "Monday") when season == "lent", do: "kyrie_pantokrator"
  def put_canticle("ep", "ot", _season, "Sunday"), do: "magnificat"
  def put_canticle("ep", "ot", _season, "Monday"), do: "cantemus_domino"
  def put_canticle("ep", "ot", _season, "Tuesday"), do: "quaerite_dominum"
  def put_canticle("ep", "ot", _season, "Wednesday"), do: "benedicite_omnia_opera_domini"
  def put_canticle("ep", "ot", _season, "Thursday"), do: "surge_illuminare"
  def put_canticle("ep", "ot", _season, "Friday"), do: "benedictis_es_domine"
  def put_canticle("ep", "ot", _season, "Saturday"), do: "ecce_deus"

  def put_canticle("ep", "nt", _season, "Sunday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Monday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Tuesday"), do: "magnificat"
  def put_canticle("ep", "nt", _season, "Wednesday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Thursday"), do: "magnificat"
  def put_canticle("ep", "nt", _season, "Friday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Saturday"), do: "magnificat"

  # stub
  def put_canticle1("ep", _), do: ""

  # this is for pslams
  # psalms is a list of models with a single read element
  def reading_names(reading) when reading |> is_list do
    reading |> Enum.map(& &1.read) |> Enum.join(", ")
  end

  # this is for the lessons
  # lessons (mp1, mp2, ep1, ep2) has field `read` which is a list of readings
  def reading_names(reading) do
    reading.read |> Enum.map(& &1.read) |> Enum.join(", ")
  end

  def put_reading(map, lesson, translation) do
    this_section = if lesson |> is_list, do: hd(lesson).section, else: lesson.section

    {section_names, section} =
      %{
        "mpp" => {:mpp_names, :mpp},
        "mp1" => {:mp1_names, :mp1},
        "mp2" => {:mp2_names, :mp2},
        "epp" => {:epp_names, :epp},
        "ep1" => {:ep1_names, :ep1},
        "ep2" => {:ep2_names, :ep2}
      }[this_section]

    map
    |> Map.put(section_names, reading_names(lesson))
    |> Map.put(section, lesson_with_body(lesson, translation))
  end

  def graces() do
    [
      {"The grace of our Lord Jesus Christ, and the love of God, and the fellowship of the Holy Spirit, be with us all evermore. Amen.",
       "2 Corinthians 13:14"},
      {"May the God of hope fill us with all joy and peace in believing through the power of the Holy Spirit. Amen.",
       "Romans 15:13"},
      {"Glory to God whose power, working in us, can do infinitely more than we can ask or imagine: Glory to him from generation to generation in the Church, and in Christ Jesus forever and ever. Amen.",
       "Ephesians 3:20-21"}
    ]
  end

  def reflectionID(date) do
    reflDate = date |> Timex.format!("{Mfull} {D}, {YYYY}")

    resp =
      Repo.one(
        from(r in Iphod.Reflection, where: [date: ^reflDate, published: true], select: {r.id})
      )

    {reflID} = if resp, do: resp, else: {0}
    reflID
  end
end

###
#  1) CofD id Christmas until next Sunday
#  2) CofD is Christmas 1 until Holy Name
#  3) if Christmas is on Sunday, there is no Christmas 1
#  4) CofD is Holy Name until following Sunday or Epiphany; which ever comes first
#  5) CofD is Christmas 2 between Christmas 2 and Epiphany (if there is a Christmas 2)
#  6) CofD is Epiphany until 1st Sunday after Epiphany
###
