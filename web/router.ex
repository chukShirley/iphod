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
    get "/printables", PrintableController, :index
    get "/versions", BibleVersionsController, :index
    get "/calendar", CalendarController, :index
    get "/calendar/prev/:month/:year", CalendarController, :prev
    get "/calendar/next/:month/:year", CalendarController, :next
    get "/morningPrayer", PrayerController, :mp
    get "/morningPrayer/:psalm", PrayerController, :mp
    get "/morningPrayer/:psalm/:text", PrayerController, :mp
    get "/eveningPrayer", PrayerController, :ep
    get "/eveningPrayer/:psalm", PrayerController, :ep
    get "/eveningPrayer/:psalm/:text", PrayerController, :ep
  end

  # Other scopes may use custom stacks.
  # scope "/api", Iphod do
  #   pipe_through :api
  # end
end
