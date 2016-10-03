use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :iphod, Iphod.Endpoint,
  http: [port: 4001],
  server: false

config :phoenix_integration,
  endpoint: Iphod.Endpoint

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :iphod, Iphod.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "iphod_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
