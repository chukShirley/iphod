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

  defp prayer_model(mpep) do
    day = Date.now(@tz)
    {sent, ref} = DailyReading.opening_sentence(mpep, day)
    dreading = DailyReading.readings(day)
    dreading
      |> Map.put(:opening_sentence, sent)
      |> Map.put(:opening_sentence_ref, ref)
      |> Map.put(:antiphon, DailyReading.antiphon(day))
      |> Map.put(:invitatory_canticle, invitatory_canticle(dreading) )
      |> Map.put(:mpp, put_psalm(dreading, :mpp))
      |> Map.put(:mp1, put_lesson(dreading, :mp1))
      |> Map.put(:mp2, put_lesson(dreading, :mp2))
      |> Map.put(:canticle1 , put_canticle1(mpep, dreading.season))
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

  defp put_canticle1("mp", "lent"), do: "benedictus"
  defp put_canticle1("mp", _) do
    ["te_deum","te_deum","te_deum", "te_deum","benedictus"]
    |> Enum.random
  end
  defp put_canticle1("ep", _), do: "" # stub

  defp put_collect_of_week(dreading) do
    c = 
      Collects.get(dreading.season, dreading.week).collects
      |> Enum.random
    c.collect
  end
end
