defmodule IphodWeb.Router do
  use IphodWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(IphodWeb.Locale)
    plug(IphodWeb.Auth, repo: Iphod.Repo)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", IphodWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PrayerController, :office)
    get("/office", PrayerController, :office)
    get("/office/:prayer", PrayerController, :office)
    get("/office/:prayer/:psalm", PrayerController, :office)
    get("/office/:prayer/:psalm/:text", PrayerController, :office)

    get("/calendar", CalendarController, :index)
    get("/calendar/next/:season", CalendarController, :season)
    get("/calendar/next/:month/:year", CalendarController, :next)
    get("/calendar/prev/:month/:year", CalendarController, :prev)
    get("/calendar/next/:month/:year/:min", CalendarController, :next)
    get("/calendar/prev/:month/:year/:min", CalendarController, :prev)
    # get "/readings/:service/:day/:month/:year", CalendarController, :service
    get("/calendar/eu/:month/:day/:year", CalendarController, :eu)
    get("/calendar/mp/:month/:day/:year", CalendarController, :mp)
    get("/calendar/ep/:month/:day/:year", CalendarController, :ep)

    get("/readmp", PrayerController, :readmp)
    get("/readmp/:psalm", PrayerController, :readmp)
    get("/readmp/:psalm/:text", PrayerController, :readmp)
    get("/mp", PrayerController, :mp)
    get("/mpfor/:date", PrayerController, :mp_for)
    get("/mp/:psalm", PrayerController, :mp)
    get("/mp/:psalm/:text", PrayerController, :mp)
    get("/mp_cutrad", PrayerController, :mp_cutrad)
    get("/晨禱傳統", PrayerController, :mp_cutrad)
    get("/mp_cusimp", PrayerController, :mp_cusimp)
    get("/晨禱簡化", PrayerController, :mp_cusimp)
    get("/morningPrayer", PrayerController, :mp)
    get("/morningPrayer/:psalm", PrayerController, :mp)
    get("/morningPrayer/:psalm/:text", PrayerController, :mp)
    get("/midday", PrayerController, :midday)
    get("/noon", PrayerController, :midday)
    get("/family", PrayerController, :family)
    get("/reconciliation", PrayerController, :reconciliation)
    get("/timeofdeath", PrayerController, :timeofdeath)
    get("/tothesick", PrayerController, :tothesick)
    get("/communiontosick", PrayerController, :communiontosick)

    get("/readep", PrayerController, :readep)
    get("/readep/:psalm", PrayerController, :readep)
    get("/readep/:psalm/:text", PrayerController, :readep)
    get("/eveningPrayer", PrayerController, :ep)
    get("/eveningPrayer/:psalm", PrayerController, :ep)
    get("/eveningPrayer/:psalm/:text", PrayerController, :ep)
    get("/ep", PrayerController, :ep)
    get("/epfor/:date", PrayerController, :ep_for)
    get("/ep_cutrad", PrayerController, :ep_cutrad)
    get("/晚報傳統祈禱", PrayerController, :ep_cutrad)
    get("/ep_cutsimp", PrayerController, :ep_cusimp)
    get("/晚祷简化", PrayerController, :ep_cusimp)
    get("/ep/:psalm", PrayerController, :ep)
    get("/ep/:psalm/:text", PrayerController, :ep)
    get("/compline", PrayerController, :compline)
    get("/printables", PrintableController, :index)
    get("/versions", BibleVersionsController, :index)

    get("/mindex", CalendarController, :mindex)

    get("/resources/index", ResourcesController, :index)
    get("/resources/show/:id", ResourcesController, :show)
    get("/resources/new", ResourcesController, :new)
    get("/resources/send/:filename", ResourcesController, :send)
    get("/resources/send/printresources/:filename", ResourcesController, :send)
    get("/printresources", ResourcesController, :printresources)
    get("/linkresources", ResourcesController, :linkresources)
    get("/humor", ResourcesController, :humor)
    get("/inserts", ResourcesController, :inserts)
    # get "/resources/create/:resources", ResourcesController, :create
    resources("/resources", ResourcesController)
    # get "/printresources", ResourceController, :printresources
    # get "/linkresources", ResourceController, :linkresources
    # get "/humor", ResourceController, :humor
    # get "/uploadresource", ResourceController, :uploadresource

    resources("/reflections", ReflectionController)

    resources("/users", UserController)

    resources("/registrations", RegistrationController, only: [:new, :create])

    get("/login", SessionController, :new)
    post("/login", SessionController, :create)
    get("/logout", SessionController, :delete)

    resources("/stations", StationsController)
  end

  # Other scopes may use custom stacks.
  # scope "/api", Iphod do
  #   pipe_through :api
  # end
end
