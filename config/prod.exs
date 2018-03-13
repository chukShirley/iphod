use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :iphod, IphodWeb.Endpoint,
  load_from_system_env: true,
  http: [port: 8080],
  url: [  scheme: "http",
          host: "localhost", 
          port: 8080
       ],
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json",
  # secret_key_base: System.get_env("SECRET_KEYBASE"),
  secret_key_base:  "!jy!R95NwKCk&=kXD_h9+_sUdgY2P_Iu9Db$MM6KdDmsWEV!QS#1Emguzxt#hCrL",
  server: true,
  code_reloader: false,
  version: Application.spec(:iphod, :vsn)

config :phoenix_distillery, PhoenixDistillery.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [  host: "localhost", 
          port: 8080
       ],
  root: ".",
  cache_static_manifest: "priv/static/manifest.json",
  server: true,
  version: Mix.Project.config[:version]

config :iphod,    Iphod.Repo,
       adapter:   Ecto.Adapters.Postgres,
       hostname:  "localhost",
       username:  "frpaulas",
       password:  "Barafundle1570",
       database:  "legereme",
       pool_size: 10
# 
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :iphod, IphodWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
##
#     config :iphod, IphodWeb.Endpoint, 
#     server: true,
#     http: [port: 8888],
#     url: [host: "legereme.com"],
#     root: ".",
#     cache_static_manifest: "priv/static/manifest.json",
#     server: true,
#     version: "0.0.1" # Mix.Project.config[:version]
#
#
# You will also need to set the application root to `.` in order
# for the new static assets to be served after a hot upgrade:
#
#     config :iphod, IphodWeb.Endpoint, root: "."

# Finally import the config/prod.secret.exs
# which should be versioned separately.
# import_config "prod.secret.exs"
