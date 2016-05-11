require IEx
defmodule Iphod.PrayerController do
  use Iphod.Web, :controller
  use Timex
  @tz "America/Los_Angeles"

  def mp(conn, _params) do
    render conn, "mp.html", model: prayer_model("mp")
  end

  def ep(conn, _params) do
    render conn, "ep.html", model: prayer_model("ep")
  end

  defp prayer_model("mp") do
    day = Date.now(@tz)
    {sent, ref} = DailyReading.opening_sentence("mp", day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> Map.put(:mpp, put_psalm(dreading, :mpp))
      |> Map.put(:mp1, put_lesson(dreading, :mp1))
      |> Map.put(:mp2, put_lesson(dreading, :mp2))
      |> Map.put(:ot_canticle, put_canticle("mp", "ot", dreading.season, dreading.day))
      |> Map.put(:nt_canticle, put_canticle("mp", "nt", dreading.season, dreading.day))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading))
  end
  defp prayer_model("ep") do
    day = Date.now(@tz)
    {sent, ref} = DailyReading.opening_sentence("ep", day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> Map.put(:epp, put_psalm(dreading, :epp))
      |> Map.put(:ep1, put_lesson(dreading, :ep1))
      |> Map.put(:ep2, put_lesson(dreading, :ep2))
      |> Map.put(:ot_canticle, put_canticle("ep", "ot", dreading.season, dreading.day))
      |> Map.put(:nt_canticle, put_canticle("ep", "nt", dreading.season, dreading.day))
      |> Map.put(:collect_of_week, put_collect_of_week(dreading))
  end

  defp invitatory_canticle(dreading) do
    cond do
      dreading.season == "lent" -> "lent_venite"
      dreading.season == "easter" && dreading.week == "1" -> "pascha_nostrum"
      true -> ["venite", "jubilate"] |> Enum.random
    end
  end

  defp put_psalm(dreading, psx) do
    dreading[psx]
    |> Enum.map(fn(ps)->
      ps |> Map.put(:body, Psalms.to_html( ps.read, "Coverdale") )
    end)
  end
  defp put_lesson(dreading, lsx) do
    dreading[lsx] 
    |> Enum.map(fn(lsn)->
      lsn |> Map.put(:body, EsvText.request(lsn.read, false) )
    end)
  end

  defp put_canticle("mp", "ot", "advent", "Sunday"),    do: "surge_illuminare"
  defp put_canticle("mp", "ot", "lent",   "Sunday"),    do: "kyrie_pantokrator"
  defp put_canticle("mp", "ot", "easter", "Sunday"),    do: "cantemus_domino"
  defp put_canticle("mp", "ot", _,        "Sunday"),    do: "benedictus"
  defp put_canticle("mp", "ot", _,        "Monday"),    do: "ecce_deus"
  defp put_canticle("mp", "ot", _,        "Tuesday"),   do: "benedictis_es_domine"
  defp put_canticle("mp", "ot", "lent",   "Wednesday"), do: "kyrie_pantokrator"
  defp put_canticle("mp", "ot", _,        "Wednesday"), do: "surge_illuminare"
  defp put_canticle("mp", "ot", _,        "Thursday"),  do: "cantemus_domino"
  defp put_canticle("mp", "ot", "lent",   "Friday"),    do: "kyrie_pantokrator"
  defp put_canticle("mp", "ot", _,        "Friday"),    do: "quaerite_dominum"
  defp put_canticle("mp", "ot", _,        "Saturday"),  do: "benedicite_omnia_opera_domini"

  defp put_canticle("mp", "nt", "advent", "Sunday"),    do: "benedictus"
  defp put_canticle("mp", "nt", "lent",   "Sunday"),    do: "benedictus"
  defp put_canticle("mp", "nt", _,        "Sunday"),    do: "te_deum"
  defp put_canticle("mp", "nt", _,        "Monday"),    do: "magna_et_mirabilia"
  defp put_canticle("mp", "nt", _,        "Tuesday"),   do: "dignus_es"
  defp put_canticle("mp", "nt", _,        "Wednesday"), do: "benedictus"
  defp put_canticle("mp", "nt", "advent", "Thursday"),  do: "magna_et_mirabilia"
  defp put_canticle("mp", "nt", "lent",   "Thursday"),  do: "magna_et_mirabilia"
  defp put_canticle("mp", "nt", _,        "Thursday"),  do: "gloria_in_excelsis"
  defp put_canticle("mp", "nt", _,        "Friday"),    do: "dignus_es"
  defp put_canticle("mp", "nt", _,        "Saturday"),  do: "magna_et_mirabilia"

  defp put_canticle("ep", "ot", _,        "Sunday"),    do: "magnificat"
  defp put_canticle("ep", "ot", "lent",   "Monday"),    do: "kyrie_pantokrator"
  defp put_canticle("ep", "ot", _,        "Monday"),    do: "cantemus_domino"
  defp put_canticle("ep", "ot", _,        "Tuesday"),   do: "quaerite_dominum"
  defp put_canticle("ep", "ot", _,        "Wednesday"), do: "benedicite_omnia_opera_domini"
  defp put_canticle("ep", "ot", _,        "Thursday"),  do: "surge_illuminare"
  defp put_canticle("ep", "ot", _,        "Friday"),    do: "benedictis_es_domine"
  defp put_canticle("ep", "ot", _,        "Saturday"),  do: "ecce_deus"

  defp put_canticle("ep", "nt", _,        "Sunday"),    do: "nunc_dimittis"
  defp put_canticle("ep", "nt", _,        "Monday"),    do: "nunc_dimittis"
  defp put_canticle("ep", "nt", _,        "Tuesday"),   do: "magnificat"
  defp put_canticle("ep", "nt", _,        "Wednesday"), do: "nunc_dimittis"
  defp put_canticle("ep", "nt", _,        "Thursday"),  do: "magnificat"
  defp put_canticle("ep", "nt", _,        "Friday"),    do: "nunc_dimittis"
  defp put_canticle("ep", "nt", _,        "Saturday"),  do: "magnificat"

  defp put_canticle1("ep", _), do: "" # stub

  defp put_collect_of_week(dreading) do
    c = 
      Collects.get(dreading.season, dreading.week).collects
      |> Enum.random
    c.collect
  end
end