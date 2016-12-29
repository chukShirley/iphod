require IEx
defmodule Iphod.PrayerController do
  use Iphod.Web, :controller
  use Timex
  import BibleText, only: [lesson_with_body: 2]
  @tz "America/Los_Angeles"
  @dayNames ~w( Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
  @christmasDays ~w( Dec29 Dec30 Dec31 Jan02 Jan03 Jan04 Jan05 )

  def mp(conn, params) do
    select_language params
    {psalm, text} = translations(params)
    conn
      |> put_layout("app.html")
      |> render( "mp.html", model: prayer_model("mp", psalm, text), page_controller: "prayer")
  end

  def midday(conn, _params) do
    conn
      |> put_layout("app.html")
      |> render("midday.html", page_controller: "prayer")
  end

  def ep(conn, params) do
    select_language params
    {psalm, text} = translations(params)
    conn
      |> put_layout("app.html")
      |> render( "ep.html", model: prayer_model("ep", psalm, text), page_controller: "prayer")
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

  def office(conn, params) do
    case params["prayer"] do
      "mp"              -> mp(conn, params)
      "ep"              -> ep(conn, params)
      "midday"          -> midday(conn, params)
      "compline"        -> compline(conn, params)
      "family"          -> family(conn, params)
      "reconciliation"  -> reconciliation(conn, params)
      "timeofdeath"     -> timeofdeath(conn, params)
      "tothesick"       -> tothesick(conn, params)
      _ ->
        conn
          |> put_layout("local_office.html")
          |> render(page_controller: "prayer")
    end
  end

  def mp_cusimp(conn, _params), do: xlate conn, "mp", "cu89s", "zh"
  def mp_cutrad(conn, _params), do: xlate conn, "mp", "cu89t", "zh"
  def ep_cusimp(conn, _params), do: xlate conn, "ep", "cu89s", "zh"
  def ep_cutrad(conn, _params), do: xlate conn, "ep", "cu89t", "zh"
    
  def xlate(conn, mpep, ver, lang) do
    Gettext.put_locale Iphod.Gettext, lang
    conn
      |> put_layout("app.html")
      |> render( "#{mpep}.html", model: prayer_model(mpep, ver, ver))    
  end

  def readmp(conn, params) do
    select_language params
    {psalm, text} = translations(params)
    conn
      |> put_layout("readable.html")
      |> render( "mp.html", model: prayer_model("mp", psalm, text))
  end

  def readep(conn, params) do
    select_language params
    {psalm, text} = translations(params)
    conn
      |> put_layout("readable.html")
      |> render( "ep.html", model: prayer_model("ep", psalm, text))
  end

# HELPERS ------

  def select_language(params) do
    unless params["locale"], do: Gettext.put_locale Iphod.Gettext, "en"
  end

  def translations(map) do
    psalm = if map |> Map.has_key?("psalm"), do: map["psalm"], else: "Coverdale"
    text  = if map |> Map.has_key?("text"), do: map["text"], else: "ESV"
    {psalm, text}
  end

  def prayer_model("mp", psalm_translation, text_translation) do
    day = Date.now(@tz)
    day_of_week = day |> Timex.weekday |> Timex.day_name
    {sent, ref} = DailyReading.opening_sentence("mp", day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> Map.put(:mpp, lesson_with_body(dreading[:mpp], psalm_translation))
      |> Map.put(:mp1, lesson_with_body(dreading[:mp1], text_translation))
      |> Map.put(:mp2, lesson_with_body(dreading[:mp2], text_translation))
      |> Map.put(:ot_canticle, put_canticle("mp", "ot", dreading.season, day_of_week))
      |> Map.put(:nt_canticle, put_canticle("mp", "nt", dreading.season, day_of_week))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading))
      |> Map.put(:day, day_of_week)
  end
  def prayer_model("ep", psalm_translation, text_translation) do
    day = Date.now(@tz)
    day_of_week = day |> Timex.weekday |> Timex.day_name
    {sent, ref} = DailyReading.opening_sentence("ep", day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> Map.put(:epp, lesson_with_body(dreading[:epp], psalm_translation))
      |> Map.put(:ep1, lesson_with_body(dreading[:ep1], text_translation))
      |> Map.put(:ep2, lesson_with_body(dreading[:ep2], text_translation))
      |> Map.put(:ot_canticle, put_canticle("ep", "ot", dreading.season, day_of_week))
      |> Map.put(:nt_canticle, put_canticle("ep", "nt", dreading.season, day_of_week))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading))
      |> Map.put(:day, day_of_week)
  end

  def invitatory_canticle(dreading) do
    cond do
      dreading.season == "lent" -> "lent_venite"
      dreading.season == "easter" && dreading.week == "1" -> "pascha_nostrum"
      true -> ["venite", "jubilate"] |> Enum.random
    end
  end

  def put_canticle("mp", "ot", season, "Sunday") when season == "advent",    do: "surge_illuminare"
  def put_canticle("mp", "ot", season, "Sunday") when season == "easter",    do: "cantemus_domino"
  def put_canticle("mp", "ot", season,   "Sunday") when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season,   "Wednesday") when season == "lent", do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season,   "Friday") when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", _season,        "Sunday"),    do: "benedictus"
  def put_canticle("mp", "ot", _season,        "Monday"),    do: "ecce_deus"
  def put_canticle("mp", "ot", _season,        "Tuesday"),   do: "benedictis_es_domine"
  def put_canticle("mp", "ot", _season,        "Wednesday"), do: "surge_illuminare"
  def put_canticle("mp", "ot", _season,        "Thursday"),  do: "cantemus_domino"
  def put_canticle("mp", "ot", _season,        "Friday"),    do: "quaerite_dominum"
  def put_canticle("mp", "ot", _season,        "Saturday"),  do: "benedicite_omnia_opera_domini"

  def put_canticle("mp", "nt", season, "Sunday") when season == "advent",    do: "benedictus"
  def put_canticle("mp", "nt", season, "Thursday") when season == "advent",  do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", season,   "Sunday") when season == "lent",    do: "benedictus"
  def put_canticle("mp", "nt", season,   "Thursday") when season == "lent",  do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", _season,        "Sunday"),    do: "te_deum"
  def put_canticle("mp", "nt", _season,        "Monday"),    do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", _season,        "Tuesday"),   do: "dignus_es"
  def put_canticle("mp", "nt", _season,        "Wednesday"), do: "benedictus"
  def put_canticle("mp", "nt", _season,        "Thursday"),  do: "gloria_in_excelsis"
  def put_canticle("mp", "nt", _season,        "Friday"),    do: "dignus_es"
  def put_canticle("mp", "nt", _season,        "Saturday"),  do: "magna_et_mirabilia"

  def put_canticle("ep", "ot", season,   "Monday") when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("ep", "ot", _season,        "Sunday"),    do: "magnificat"
  def put_canticle("ep", "ot", _season,        "Monday"),    do: "cantemus_domino"
  def put_canticle("ep", "ot", _season,        "Tuesday"),   do: "quaerite_dominum"
  def put_canticle("ep", "ot", _season,        "Wednesday"), do: "benedicite_omnia_opera_domini"
  def put_canticle("ep", "ot", _season,        "Thursday"),  do: "surge_illuminare"
  def put_canticle("ep", "ot", _season,        "Friday"),    do: "benedictis_es_domine"
  def put_canticle("ep", "ot", _season,        "Saturday"),  do: "ecce_deus"

  def put_canticle("ep", "nt", _season,        "Sunday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season,        "Monday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season,        "Tuesday"),   do: "magnificat"
  def put_canticle("ep", "nt", _season,        "Wednesday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season,        "Thursday"),  do: "magnificat"
  def put_canticle("ep", "nt", _season,        "Friday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season,        "Saturday"),  do: "magnificat"

  def put_canticle1("ep", _), do: "" # stub

  def put_collect_of_week(dreading) do
    c = 
      cond do
        @dayNames |> Enum.member?(dreading.title) ->
          Collects.get(dreading.season, dreading.week).collects
        @christmasDays |> Enum.member?(dreading.day) ->
          Collects.get(dreading.season, dreading.week).collects
        true ->
          Collects.get("redLetter", dreading.day).collects
      end
      |> Enum.random
    c.collect
  end
end
