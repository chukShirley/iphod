# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :mix_docker, image: "iphod/legereme"

config :iphod,
  ecto_repos: [Iphod.Repo]

# Configures the endpoint
config :iphod, IphodWeb.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  http: [port: System.get_env("PORT") || 4000],
  url: [host: "localhost", scheme: "http", port: System.get_env("PORT") || 4000],
  # secret_key_base: "supersecretlongkey",
  # to generate a super secret long key: `mix phoenix.gen.secret`
  # secret_key_base: System.get_env("SECRET_KEYBASE"),
  secret_key_base: "Ave4O7mnepk50TgDq4VWa32gCLGYVDqd+DHOZLYFGEsKZIlCeocth2XH5r2rQkz7",
  root: Path.dirname(__DIR__),
  server: true,
  render_errors: [view: IphodWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: IphodWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  # watchers: [node: ["run", "watch", cd: Path.expand("../assets", __DIR__)]]
  watchers: [
    node: [
      "node_modules/brunch/bin/brunch",
      "watch",
      "--stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

import_config "#{Mix.env()}.exs"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# for automagic running of tests
# `$> mix test.watch`

if Mix.env() == :dev do
  config :mix_test_watch,
    clear: true,
    tasks: ~w(test dogma)
end

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :iphod, IphodWeb.Gettext, default_locale: "en"
