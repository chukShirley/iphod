defmodule Iphod.Router do
  use Iphod.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Iphod do
    pipe_through :browser # Use the default browser stack

    get "/", CalendarController, :index
    get "/calendar", CalendarController, :index
    get "/calendar/next/:season", CalendarController, :season
    get "/calendar/next/:month/:year", CalendarController, :next
    get "/calendar/prev/:month/:year", CalendarController, :prev
    get "/calendar/next/:month/:year/:min", CalendarController, :next
    get "/calendar/prev/:month/:year/:min", CalendarController, :prev
    get "/readmp", PrayerController, :readmp
    get "/readmp/:psalm", PrayerController, :readmp
    get "/readmp/:psalm/:text", PrayerController, :readmp
    get "/mp", PrayerController, :mp
    get "/mp/:psalm", PrayerController, :mp
    get "/mp/:psalm/:text", PrayerController, :mp
    get "/morningPrayer", PrayerController, :mp
    get "/morningPrayer/:psalm", PrayerController, :mp
    get "/morningPrayer/:psalm/:text", PrayerController, :mp
    get "/readep", PrayerController, :readep
    get "/readep/:psalm", PrayerController, :readep
    get "/readep/:psalm/:text", PrayerController, :readep
    get "/eveningPrayer", PrayerController, :ep
    get "/eveningPrayer/:psalm", PrayerController, :ep
    get "/eveningPrayer/:psalm/:text", PrayerController, :ep
    get "/ep", PrayerController, :ep
    get "/ep/:psalm", PrayerController, :ep
    get "/ep/:psalm/:text", PrayerController, :ep
    get "/printables", PrintableController, :index
    get "/versions", BibleVersionsController, :index

    get "/mindex", CalendarController, :mindex

    resources "/reflections", ReflectionController

  end

  # Other scopes may use custom stacks.
  # scope "/api", Iphod do
  #   pipe_through :api
  # end
end
