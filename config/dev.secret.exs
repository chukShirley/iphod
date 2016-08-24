use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :iphod, Iphod.Endpoint,
  http: [port: 4000],
  url: [ host: "localhost"],
  root: ".",
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: "0b0ly5fphaXAnUk6vbZ6JMnJN5bX1SvcMUoGReUWHPlMWoPeHzRWFWYGrYQRtL/x",
  # server: true,
  version: "0.0.1" # Mix.Project.config[:version]

# Configure your database
config :iphod, Iphod.Repo,
       adapter: Ecto.Adapters.Postgres,
       hostname: "legereme.com",
       username: "frpaulas",
       password: "Barafundle1570",
       database: "legereme",
       pool_size: 20


