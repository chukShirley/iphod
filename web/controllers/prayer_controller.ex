require IEx
defmodule Iphod.PrayerController do
  use Iphod.Web, :controller
  use Timex
  import BibleText, only: [lesson_with_body: 2]
  import Lityear, only: [right_after_ash_wednesday?: 1, right_after_ascension?: 1]
  @tz "America/Los_Angeles"
  @dayNames ~w( Monday Tuesday Wednesday Thursday Friday Saturday Sunday)
  @christmasDays ~w( Dec29 Dec30 Dec31 Jan02 Jan03 Jan04 Jan05 )

  def mp(conn, params) do
    if params["text"] |> is_nil do
      render conn, "get_params.html", model: need_params(params, "mp"), page_controller: "prayer"
    else
      select_language params
      {psalm, text} = translations(params)
      model = prayer_model("mp", psalm, text)
      conn
        |> put_layout("app.html")
        |> render( "mp.html", model: model, page_controller: "prayer")
    end
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
      render conn, "get_params.html", model: need_params(params, "ep"), page_controller: "prayer"
    else
      select_language params
      {psalm, text} = translations(params)
      conn
        |> put_layout("app.html")
        |> render( "ep.html", model: prayer_model("ep", psalm, text), page_controller: "prayer")
    end
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
    day = Timex.now(@tz) |> Timex.to_date
    day_of_week = day |> Timex.weekday |> Timex.day_name
    {sent, ref} = DailyReading.opening_sentence("mp", day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> put_reading(dreading[:mpp], psalm_translation)
      |> put_reading(dreading[:mp1], text_translation)
      |> put_reading(dreading[:mp2], text_translation)
      |> Map.put(:ot_canticle, put_canticle("mp", "ot", dreading.season, day_of_week))
      |> Map.put(:nt_canticle, put_canticle("mp", "nt", dreading.season, day_of_week))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading, day))
      |> Map.put(:day, day_of_week)
  end
  
  def prayer_model("ep", psalm_translation, text_translation) do
    day = Timex.now(@tz) |> Timex.to_date
    day_of_week = day |> Timex.weekday |> Timex.day_name
    {sent, ref} = DailyReading.opening_sentence("ep", day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> put_reading(dreading[:epp], psalm_translation)
      |> put_reading(dreading[:ep1], text_translation)
      |> put_reading(dreading[:ep2], text_translation)
      |> Map.put(:ot_canticle, put_canticle("ep", "ot", dreading.season, day_of_week))
      |> Map.put(:nt_canticle, put_canticle("ep", "nt", dreading.season, day_of_week))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading, day))
      |> Map.put(:day, day_of_week)
  end

  def invitatory_canticle(dreading) do
    cond do
      dreading.season == "lent" -> "lent_venite"
      dreading.season == "easterDay" && dreading.week == "1" -> "pascha_nostrum"
      dreading.season == "easter" -> ["venite", "jubilate", "pascha_nostrum"] |> Enum.random
      true -> ["venite", "jubilate"] |> Enum.random
    end
  end

  def put_canticle("mp", "ot", season,  "Sunday")    when season == "advent",  do: "surge_illuminare"
  def put_canticle("mp", "ot", season,  "Sunday")    when season == "easter",  do: "cantemus_domino"
  def put_canticle("mp", "ot", season,  "Sunday")    when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season,  "Monday")    when season == "lent",    do: "quaerite_dominum"
  def put_canticle("mp", "ot", season,  "Tuesday")   when season == "lent",    do: "quaerite_dominum"
  def put_canticle("mp", "ot", season,  "Wednesday") when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season,  "Thursday")  when season == "lent",    do: "quaerite_dominum"
  def put_canticle("mp", "ot", season,  "Friday")    when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", season,  "Saturday")  when season == "lent",    do: "quaerite_dominum"
  def put_canticle("mp", "ot", _season, "Sunday"),    do: "benedictus"
  def put_canticle("mp", "ot", _season, "Monday"),    do: "ecce_deus"
  def put_canticle("mp", "ot", _season, "Tuesday"),   do: "benedictis_es_domine"
  def put_canticle("mp", "ot", _season, "Wednesday"), do: "surge_illuminare"
  def put_canticle("mp", "ot", _season, "Thursday"),  do: "cantemus_domino"
  def put_canticle("mp", "ot", _season, "Friday"),    do: "quaerite_dominum"
  def put_canticle("mp", "ot", _season, "Saturday"),  do: "benedicite_omnia_opera_domini"

  def put_canticle("mp", "nt", season,  "Sunday")     when season == "advent",  do: "benedictus"
  def put_canticle("mp", "nt", season,  "Thursday")   when season == "advent",  do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", season,  "Sunday")     when season == "lent",    do: "benedictus"
  def put_canticle("mp", "nt", season,  "Thursday")   when season == "lent",    do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", _season, "Sunday"),    do: "benedictus"
  def put_canticle("mp", "nt", _season, "Monday"),    do: "benedictus"
  def put_canticle("mp", "nt", _season, "Tuesday"),   do: "benedictus"
  def put_canticle("mp", "nt", _season, "Wednesday"), do: "benedictus"
  def put_canticle("mp", "nt", _season, "Thursday"),  do: "benedictus"
  def put_canticle("mp", "nt", _season, "Friday"),    do: "benedictus"
  def put_canticle("mp", "nt", _season, "Saturday"),  do: "benedictus"

  def put_canticle("ep", "ot", season,  "Monday")     when season == "lent",    do: "kyrie_pantokrator"
  def put_canticle("ep", "ot", _season, "Sunday"),    do: "magnificat"
  def put_canticle("ep", "ot", _season, "Monday"),    do: "cantemus_domino"
  def put_canticle("ep", "ot", _season, "Tuesday"),   do: "quaerite_dominum"
  def put_canticle("ep", "ot", _season, "Wednesday"), do: "benedicite_omnia_opera_domini"
  def put_canticle("ep", "ot", _season, "Thursday"),  do: "surge_illuminare"
  def put_canticle("ep", "ot", _season, "Friday"),    do: "benedictis_es_domine"
  def put_canticle("ep", "ot", _season, "Saturday"),  do: "ecce_deus"

  def put_canticle("ep", "nt", _season, "Sunday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Monday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Tuesday"),   do: "magnificat"
  def put_canticle("ep", "nt", _season, "Wednesday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Thursday"),  do: "magnificat"
  def put_canticle("ep", "nt", _season, "Friday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _season, "Saturday"),  do: "magnificat"

  def put_canticle1("ep", _), do: "" # stub

  def put_collect_of_week(dreading, date) do
    c = 
      cond do
        dreading.title == "Monday of Easter Week"     -> Collects.get("easterWeek", "1").collects
        dreading.title == "Tuesday of Easter Week"    -> Collects.get("easterWeek", "2").collects
        dreading.title == "Wednesday of Easter Week"  -> Collects.get("easterWeek", "3").collects
        dreading.title == "Thursday of Easter Week"   -> Collects.get("easterWeek", "4").collects
        dreading.title == "Friday of Easter Week"     -> Collects.get("easterWeek", "5").collects
        dreading.title == "Saturday of Easter Week"   -> Collects.get("easterWeek", "6").collects

        date |> right_after_ash_wednesday?            -> Collects.get("ashWednesday", "1").collects

        date |> right_after_ascension?                -> Collects.get("ascension", "1").collects

        @christmasDays |> Enum.member?(dreading.day)  -> Collects.get(dreading.season, dreading.week).collects

        @dayNames |> Enum.member?(dreading.title)     -> Collects.get(dreading.season, dreading.week).collects

        @dayNames |> Enum.member?(dreading.day)       -> Collects.get(dreading.season, dreading.week).collects

        true                                          -> Collects.get("redLetter", dreading.day).collects
      end
      |> Enum.random
    c.collect
  end

  def reading_names(reading) do
    reading |> Enum.map(&(&1.read)) |> Enum.join(", ")
  end

 def put_reading(map, lesson, translation) do
   {section_names, section} = 
      %{  "mpp" => {:mpp_names, :mpp}, 
          "mp1" => {:mp1_names, :mp1}, 
          "mp2" => {:mp2_names, :mp2},
          "epp" => {:epp_names, :epp},
          "ep1" => {:ep1_names, :ep1},
          "ep2" => {:ep2_names, :ep2},
      }[hd(lesson).section]
   map
   |> Map.put(section_names, reading_names(lesson))
   |> Map.put(section, lesson_with_body(lesson, translation))
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
