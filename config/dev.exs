use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :iphod, Iphod.Endpoint,
  http: [port: 4000],
  url: [host: "localhost", port: 4000],
  root: ".",
  server: true,
  version: "0.0.1", #Mix.Project.config[:version],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  secret_key_base: System.get_env("SECRET_KEYBASE"),
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin", cd: Path.expand("../", __DIR__)]]

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
config :iphod,    Iphod.Repo,
       adapter:   Ecto.Adapters.Postgres,
       hostname:  "legereme.com",
       username:  "frpaulas",
       password:  "Barafundle1570",
       database:  "legereme",
       pool_size: 10

