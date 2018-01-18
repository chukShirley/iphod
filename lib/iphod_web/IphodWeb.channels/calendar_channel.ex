require IEx
require Poison
defmodule IphodWeb.CalendarChannel do
  use IphodWeb, :channel
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
    push socket, "this_month", get_month(Timex.now)
    {:noreply, socket}
  end

  def handle_in("request_calendar", _, socket), do: handle_info :after_join, socket

  def handle_in("request_move_month", [month, year, "next"], socket) do
    push socket, "this_month", shift_get_month(month, year, 1)
    {:noreply, socket}
  end

  def handle_in("request_move_month", [month, year, "last"], socket) do
    push socket, "this_month", shift_get_month(month, year, -1)   
    {:noreply, socket}
  end

  def handle_in("get_text", [of_type, date], socket) do
    IO.puts "GET TEXT: #{of_type}, #{date}"
    {:noreply, socket}
  end

  def shift_get_month(month, year, n) do
    imonth = Timex.month_to_num(month)
    iyr = String.to_integer(year)
    IO.puts "IMONTH: #{imonth}, IYEAR: #{iyr}"
    Timex.to_date({iyr, imonth, 1}) 
    |> Timex.shift(months: n)
    |> get_month    
  end

  def get_month(date) do
    days = list_of_weeks_from begin_month(date), end_month(date)
    %{  calendar: days,
        month:    date |> Timex.format!("{Mfull}"),
        year:     date |> Timex.format!("{YYYY}")
    }
  end

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
              colors: SundayReading.colors(start_date),
              daily: DailyReading.readings(start_date),
              sunday: SundayReading.readings(start_date),
              today: start_date == Timex.now
          }
    new_head = [day | head]
    new_date = start_date |> Timex.shift(days: 1)
    _list_of_weeks_from(new_date, end_date, n+1, [new_head|list])
  end

  defp authorized?(_payload), do: true # everyone is authorized
end