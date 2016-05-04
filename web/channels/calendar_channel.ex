require IEx
require Poison
defmodule Iphod.CalendarChannel do
  use Iphod.Web, :channel
  use Timex

  def join("calendar", payload, socket) do
    if authorized?(payload) do
      # send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    today = Date.now()
    msg = list_of_weeks_from begin_month(today), end_month(today)
    push socket, "this_month", %{calendar: msg}
    {:noreply, socket}
  end

  def handle_in("request_calendar", _, socket), do: handle_info :after_join, socket

  def begin_month(date) do
    bom = date |> Timex.beginning_of_month
    bwk = bom |> Timex.days_to_beginning_of_week(7)
    Timex.shift bom, days: -bwk
  end

  def end_month(date) do
    bem = date |> Timex.end_of_month
    ewk = bem |> Timex.days_to_end_of_week(7)
    Timex.shift bem, days: ewk
  end

  def list_of_weeks_from(start_date, end_date) do
    _list_of_weeks_from start_date, end_date, 1, [ [] ]
  end

  def _list_of_weeks_from(start_date, end_date, 8, [head|list]) do
    new_head = Enum.reverse head
    if start_date |> Timex.before?(end_date) do
      _list_of_weeks_from(start_date, end_date, 1, [ [] | [%{days: new_head}|list] ])
    else
      [%{days: new_head}|list] |> Enum.reverse
    end
  end

  def _list_of_weeks_from(start_date, end_date, n, [head|list]) do
    day = %{  date: start_date |> Timex.format!("{WDfull} {Mfull} {D}, {YYYY}"),
              name: start_date |> Timex.format!("{WDfull}"),
              dayOfMonth: start_date |> Timex.format!("{D}"),
              color: "green",
              daily: DailyReading.readings(start_date),
              sunday: SundayReading.readings(start_date)
          }
    new_head = [day | head]
    new_date = start_date |> Timex.shift(days: 1)
    _list_of_weeks_from(new_date, end_date, n+1, [new_head|list])
  end

  defp authorized?(_payload), do: true # everyone is authorized
end