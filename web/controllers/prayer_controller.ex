require IEx
defmodule Iphod.PrayerController do
  use Iphod.Web, :controller
  use Timex
  import BibleText, only: [lesson_with_body: 2]
  @tz "America/Los_Angeles"

  def mp(conn, params) do
    select_language params
    {psalm, text} = translations(params)
    conn
      |> put_layout("app.html")
      |> render( "mp.html", model: prayer_model("mp", psalm, text))
  end

  def ep(conn, params) do
    select_language params
    {psalm, text} = translations(params)
    conn
      |> put_layout("app.html")
      |> render( "ep.html", model: prayer_model("ep", psalm, text))
  end

  def readmp(conn, params) do
    {psalm, text} = translations(params)
    conn
      |> put_layout("readable.html")
      |> render( "mp.html", model: prayer_model("mp", psalm, text))
  end

  def readep(conn, params) do
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
      |> Map.put(:ot_canticle, put_canticle("mp", "ot", dreading.season, dreading.day))
      |> Map.put(:nt_canticle, put_canticle("mp", "nt", dreading.season, dreading.day))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading))
  end
  def prayer_model("ep", psalm_translation, text_translation) do
    day = Date.now(@tz)
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
      |> Map.put(:ot_canticle, put_canticle("ep", "ot", dreading.season, dreading.day))
      |> Map.put(:nt_canticle, put_canticle("ep", "nt", dreading.season, dreading.day))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading))
  end

  def invitatory_canticle(dreading) do
    cond do
      dreading.season == "lent" -> "lent_venite"
      dreading.season == "easter" && dreading.week == "1" -> "pascha_nostrum"
      true -> ["venite", "jubilate"] |> Enum.random
    end
  end

  def put_canticle("mp", "ot", "advent", "Sunday"),    do: "surge_illuminare"
  def put_canticle("mp", "ot", "lent",   "Sunday"),    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", "easter", "Sunday"),    do: "cantemus_domino"
  def put_canticle("mp", "ot", _,        "Sunday"),    do: "benedictus"
  def put_canticle("mp", "ot", _,        "Monday"),    do: "ecce_deus"
  def put_canticle("mp", "ot", _,        "Tuesday"),   do: "benedictis_es_domine"
  def put_canticle("mp", "ot", "lent",   "Wednesday"), do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", _,        "Wednesday"), do: "surge_illuminare"
  def put_canticle("mp", "ot", _,        "Thursday"),  do: "cantemus_domino"
  def put_canticle("mp", "ot", "lent",   "Friday"),    do: "kyrie_pantokrator"
  def put_canticle("mp", "ot", _,        "Friday"),    do: "quaerite_dominum"
  def put_canticle("mp", "ot", _,        "Saturday"),  do: "benedicite_omnia_opera_domini"

  def put_canticle("mp", "nt", "advent", "Sunday"),    do: "benedictus"
  def put_canticle("mp", "nt", "lent",   "Sunday"),    do: "benedictus"
  def put_canticle("mp", "nt", _,        "Sunday"),    do: "te_deum"
  def put_canticle("mp", "nt", _,        "Monday"),    do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", _,        "Tuesday"),   do: "dignus_es"
  def put_canticle("mp", "nt", _,        "Wednesday"), do: "benedictus"
  def put_canticle("mp", "nt", "advent", "Thursday"),  do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", "lent",   "Thursday"),  do: "magna_et_mirabilia"
  def put_canticle("mp", "nt", _,        "Thursday"),  do: "gloria_in_excelsis"
  def put_canticle("mp", "nt", _,        "Friday"),    do: "dignus_es"
  def put_canticle("mp", "nt", _,        "Saturday"),  do: "magna_et_mirabilia"

  def put_canticle("ep", "ot", _,        "Sunday"),    do: "magnificat"
  def put_canticle("ep", "ot", "lent",   "Monday"),    do: "kyrie_pantokrator"
  def put_canticle("ep", "ot", _,        "Monday"),    do: "cantemus_domino"
  def put_canticle("ep", "ot", _,        "Tuesday"),   do: "quaerite_dominum"
  def put_canticle("ep", "ot", _,        "Wednesday"), do: "benedicite_omnia_opera_domini"
  def put_canticle("ep", "ot", _,        "Thursday"),  do: "surge_illuminare"
  def put_canticle("ep", "ot", _,        "Friday"),    do: "benedictis_es_domine"
  def put_canticle("ep", "ot", _,        "Saturday"),  do: "ecce_deus"

  def put_canticle("ep", "nt", _,        "Sunday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _,        "Monday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _,        "Tuesday"),   do: "magnificat"
  def put_canticle("ep", "nt", _,        "Wednesday"), do: "nunc_dimittis"
  def put_canticle("ep", "nt", _,        "Thursday"),  do: "magnificat"
  def put_canticle("ep", "nt", _,        "Friday"),    do: "nunc_dimittis"
  def put_canticle("ep", "nt", _,        "Saturday"),  do: "magnificat"

  def put_canticle1("ep", _), do: "" # stub

  def put_collect_of_week(dreading) do
    c = 
      Collects.get(dreading.season, dreading.week).collects
      |> Enum.random
    c.collect
  end
end
