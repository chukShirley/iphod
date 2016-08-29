require IEx
require Logger
require Poison
require Ecto.Query
alias Iphod.Repo
# alias Iphod.Reflection

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
  @email %{ from: "", topic: "", text: ""}
#  @config %{ ot: "ESV",
#             ps: "Coverdale",
#             nt: "ESV",
#             gs: "ESV",
#             fnotes: "fnotes"
#            }


#  alias Saints.Donor


  def join("iphod:readings", payload, socket) do
    if authorized?(payload) do
      # send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end



  def handle_in("init_calendar", _, socket) do
    # date = Date.now(@tz)
    # push socket, "eu_today", SundayReading.eu_today(date)
    # push socket, "mp_today", DailyReading.mp_today(date)
    # push socket, "ep_today", DailyReading.ep_today(date)
    push socket, "init_email", @email
    {:noreply, socket}  
  end

  def handle_in("get_single_reading", [vss, version, service, section], socket) do
    # resp should contain 
    #  [:collect, :colors, :date, :gs, :nt, :ofType, :ot, :ps, :season, :show, :title,
    #  :week]
    resp = BibleText.selection( vss, version, service)
    resp_name = service <> "_today"
    push socket, "single_lesson", %{resp: resp}
    {:noreply, socket}
  end

  def handle_in("get_text", ["Reflection", date], socket) do
    day = date |> String.split(" ", [parts: 2, trim: 2]) |> List.last
    resp = Repo.one(from r in Iphod.Reflection, where: [date: ^day, published: true], select: {r.author, r.markdown})
    {author, markdown} = if resp, do: resp, else: {"", "Sorry, nothing today"}
    push socket, "reflection_today", %{author: author, markdown: markdown}
    {:noreply, socket}
  end

  def handle_in("get_text", ["NextSunday", date], socket) do
    nextSunday = text_to_date(date) |> Lityear.date_next_sunday
    push socket, "eu_today", SundayReading.eu_body(nextSunday)
    {:noreply, socket}  
  end

  def handle_in("get_text", ["EU", date], socket) do
    # a couple things need to be done here
    # 1) is the date a redletter day or not
    # 2) are footnotes to be displayed or not
    day = text_to_date date
    push socket, "eu_today", SundayReading.eu_body(day)
    {:noreply, socket}  
  end
  
  def handle_in("get_text", ["MP", date], socket) do
    day = text_to_date date
    push socket, "mp_today", DailyReading.mp_body(day)
    {:noreply, socket}  
  end
  
  def handle_in("get_text", ["EP", date], socket) do
    day = text_to_date date
    push socket, "ep_today", DailyReading.ep_body(day)
    {:noreply, socket}  
  end
  
  def handle_in("get_lesson", [section, version, date], socket) when section in ~w(mp1 mp2 mpp ep1 ep2 epp) do
    day = text_to_date date
    lesson = DailyReading.lesson(day, section, version)
    push socket, "update_lesson", %{lesson: lesson}
    {:noreply, socket}
  end

  def handle_in("get_lesson", [section, version, date], socket) when section in ~w(ot ps nt gs) do
    day = text_to_date date
    lesson = SundayReading.lesson(day, section, version)
    push socket, "update_lesson", %{lesson: lesson}
    {:noreply, socket}
  end

  def handle_in("get_lesson", [_section, _version, _date], socket) do
    # day = text_to_date date
    # lesson = SundayReading.lesson(day, section, version)
    # push socket, "update_lesson", %{lesson: lesson}
    {:noreply, socket}
  end

  def handle_in("request_send_email", email, socket) do
    send_contact_me email["from"], email["topic"], email["text"]
    push socket, "new_email", @email
    {:noreply, socket}
  end


  def handle_in("get_text", date, socket) do
    handle_in("get_text", ["Reflection", date], socket)
    handle_in("get_text", ["EU", date], socket)
    handle_in("get_text", ["MP", date], socket)
    handle_in("get_text", ["EP", date], socket)
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


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp text_to_date(s) do
    {ok, okDate} = Timex.parse(s, "{WDfull} {Mfull} {D}, {YYYY}")
    {ok, date} = if ok == :error, do: Timex.parse(s, "{WDshort} {Mshort} {D} {YYYY}"), else: {ok, okDate}
    Timex.to_date date
  end
end
