require IEx
require Logger
require Poison
defmodule Iphod.IphodChannel do
  import Iphod.Mailer
  use Iphod.Web, :channel
  # import SundayReading
  # import DailyReading
  # import Psalms
  # import Lityear
  # import EsvText
  use Timex
  @tz "America/Los_Angeles"
  @email %{ from: "", topic: "", text: "", show: false}
#  @config %{ ot: "ESV",
#             ps: "Coverdale",
#             nt: "ESV",
#             gs: "ESV",
#             fnotes: "fnotes"
#            }


#  alias Saints.Donor



  def join("iphod", payload, socket) do
    if authorized?(payload) do
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end


  def handle_info(:after_join, socket) do
    msg = %{  sunday:         jsonify_reading("sunday", SundayReading.from_now, true),
              redLetter:      jsonify_reading("redletter", SundayReading.next_holy_day, true),
              today:          Date.now(@tz) |> SundayReading.formatted_date,
              daily:          Date.now(@tz) |> DailyReading.readings |> jsonify_daily(true),
              morningPrayer:  Date.now(@tz) |> DailyReading.readings |> jsonify_daily,
              eveningPrayer:  Date.now(@tz) |> DailyReading.readings |> jsonify_daily,
              email:          @email,
              config:         nil, 
              about:          false
            }
    push socket, "next_sunday", msg
    {:noreply, socket}
  end

  def jsonify_reading(ofType, r, show \\ false) do
    %{  ofType:   ofType,
        date:     r.date,
        season:   r.season,
        week:     r.week,
        title:    r.title,
        collect:  r.collect,
        ot:       r.ot,
        ps:       r.ps,
        nt:       r.nt,
        gs:       r.gs,
        show:     show
      }
  end

  def jsonify_daily(r, show \\ false) do
    %{  date: r.date,
        season: r.season,
        week: r.week,
        day: r.day,
        title: r.title,
        mp1: r.mp1,
        mp2: r.mp2,
        mpp: r.mpp,
        ep1: r.ep1,
        ep2: r.ep2,
        epp: r.epp,
        show: show,
        justToday: false
    }

  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (donors:lobby).
  def push_text(model, reading, body, ver, socket) do
    push socket, "new_text", %{model: model, section: reading.section, id: reading.id, body: body, version: ver}
  end


  def move_day(date, "tomorrow", socket) do
    date 
    |> Timex.shift(days: 1) 
    |> request_date(socket, {false, true})
  end

  def move_day(date, "yesterday", socket) do
    date 
    |> Timex.shift(days: -1) 
    |> request_date(socket, {false, true})
  end

  def move_day(date, "nextSunday", socket) do
    date 
    |> Lityear.date_next_sunday 
    |> request_date(socket, {true, false})
  end

  def move_day(date, "lastSunday", socket) do
    date 
    |> Lityear.date_last_sunday 
    |> request_date(socket, {true, false})
  end

  def request_date(date, socket, {show_sunday, show_daily}) do
    msg = %{ sunday:        jsonify_reading( "sunday", SundayReading.this_sunday(date), show_sunday ),
             redLetter:     jsonify_reading( "redletter", SundayReading.next_holy_day(date) ),
             today:         date |> SundayReading.formatted_date,
             daily:         date |> DailyReading.readings |> jsonify_daily(show_daily),
             morningPrayer: date |> DailyReading.readings |> jsonify_daily,
             eveningPrayer: date |> DailyReading.readings |> jsonify_daily,
             email:          @email,
             config:         nil, 
             about:         false
          }
    push  socket, "next_sunday", msg
          
    {:noreply, socket}  
    
  end

  def handle_in("request_move_date", this_date, socket) do
    Timex.parse!(this_date, "{WDfull} {Mfull} {D}, {YYYY}")
    |> Timex.to_date
    |> request_date(socket, {true, true})
  end

  def handle_in("request_all_text", ["morningPrayer", this_date, config], socket) do
    readings = 
      Timex.parse!(this_date, "{WDfull} {Mfull} {D}, {YYYY}")
      |> Timex.to_date
      |> DailyReading.readings
    readings.mp1 ++ readings.mp2
      |> Enum.each(fn(r)-> 
          push_text "morningPrayer", r, EsvText.request(r.read, config["fnotes"]), "ESV", socket
      end)
    readings.mpp
      |> Enum.each(fn(r)-> 
          push_text "morningPrayer", r, Psalms.to_html(r.read, config["ps"]), config["ps"], socket
      end)
    {:noreply, socket}
  end

  def handle_in("request_all_text", ["eveningPrayer", this_date, config], socket) do
    readings = 
      Timex.parse!(this_date, "{WDfull} {Mfull} {D}, {YYYY}")
      |> Timex.to_date
      |> DailyReading.readings
    readings.ep1 ++ readings.ep2
      |> Enum.each(fn(r)-> 
          push_text "eveningPrayer", r, EsvText.request(r.read, config["fnotes"]), "ESV", socket
      end)
    readings.epp
      |> Enum.each(fn(r)-> 
          push_text "eveningPrayer", r, Psalms.to_html(r.read, config["ps"]), config["ps"], socket
      end)
    {:noreply, socket}
  end

  def handle_in("request_move_day", [this_far, this_date], socket) do
    Timex.parse!(this_date, "{WDfull} {Mfull} {D}, {YYYY}")
      |> Timex.to_date
      |> move_day(this_far, socket)
  end

  def handle_in("request_text", request_model, socket) do
    request_text(request_model["ver"], request_model, socket)
  end

  def handle_in("request_named_day", [season, week], socket) do
    date = Date.now(@tz)
    msg = %{ sunday:    jsonify_reading( "sunday", SundayReading.namedReadings(season, week), true ),
             redLetter: jsonify_reading( "redletter", SundayReading.next_holy_day(date) ),
             today:     date |> SundayReading.formatted_date,
             daily:     date |> DailyReading.readings |> jsonify_daily,
             morningPrayer:  Date.now(@tz) |> DailyReading.readings |> jsonify_daily,
             eveningPrayer:  Date.now(@tz) |> DailyReading.readings |> jsonify_daily,
             email:          @email,
             config:         nil, 
             about:     false
          }
    push  socket, "next_sunday", msg
          
    {:noreply, socket}  
    
  end

  def handle_in("request_send_email", email, socket) do
    send_contact_me email["from"], email["topic"], email["text"]
    push socket, "new_email", @email
    {:noreply, socket}
  end

  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(_event, _payload, socket) do
    {:noreply, socket}
  end

  def request_text("ESV", m, socket) do
    body = EsvText.request(m["read"], m["fnotes"])
    # {ofType: "sunday", section: "ot", id: "Acts_9_1-19a", read: "Acts 9.1-19a", ver: "ESV"…}
    push socket, "new_text", %{model: m["ofType"], section: m["section"], id: m["id"], body: body, version: "ESV"}
    {:noreply, socket}
  end 

  def request_text(ver, m, socket) do
    # this should only happen on psalms
    # {ofType: "sunday", section: "ot", id: "Acts_9_1-19a", read: "Acts 9.1-19a", ver: "ESV"…}
    body = Psalms.to_html m["read"], m["ver"]
    push socket, "new_text", %{model: m["ofType"], section: m["section"], id: m["id"], body: body, version: m["ver"]}
    {:noreply, socket}
  end  

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
