use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :iphod, Iphod.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin", cd: Path.expand("../", __DIR__)]]
  # url: [host: "localhost"],
  # root: ".",
  # version: "0.0.1", #Mix.Project.config[:version],
  # server: true,

# Watch static and templates for browser reloading.
config :iphod, Iphod.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# ## Using releases
# if you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints
#

# config :phoenix, :serve_end_points, true

# Configure your database
config :iphod, Iphod.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "frpaulas",
  password: "Barafundle1570",
  database: "legereme",
  hostname: "legereme.com",
  pool_size: 10
