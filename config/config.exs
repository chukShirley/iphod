# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :iphod,
  ecto_repos: [Iphod.Repo]

# Configures the endpoint
config :iphod, Iphod.Endpoint,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "aSNEmJnAzMWTMqeNpHIZaQV5z1aNX6/fYT/OLyaJIXAWXzZe8ZllE180Tf3Iz/Ll",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Iphod.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# for automagic running of tests
# `$> mix test.watch`

if Mix.env == :dev do
  config :mix_test_watch,
    clear: true,
    tasks: ~w(test dogma)
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
import_config "config.secret.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false

config :iphod, Iphod.Gettext, default_locale: "en"
