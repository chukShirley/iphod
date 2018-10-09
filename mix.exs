defmodule Iphod.Mixfile do
  use Mix.Project

  def project do
    [
      app: :iphod,
      version: "0.0.1",
      elixir: ">= 1.6.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      deploy_dir: "/opt/StEAM/iphod/"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Iphod.Application, []},
      applications: [
        :mix,
        :phoenix,
        :phoenix_html,
        :phoenix_pubsub,
        :phoenix_integration,
        # :phoenix_live_reload, 
        :cowboy,
        :logger,
        :gettext,
        :comeonin,
        :phoenix_ecto,
        :postgrex,
        :timex,
        :httpoison,
        :mailgun,
        :earmark,
        :floki,
        :exactor,
        :edeliver
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, ">= 1.3.0"},
      {:phoenix_pubsub, "~> 1.0.2"},
      {:ecto, "~> 2.2.6"},
      {:phoenix_ecto, "~> 3.3.0"},
      {:phoenix_html, ">= 2.6.2"},
      {:phoenix_live_reload, "~> 1.1.3", only: :dev},
      {:phoenix_integration, "~> 0.3.0"},
      {:postgrex, ">= 0.13.3"},
      {:gettext, "~> 0.13.1"},
      {:html_entities, "~> 0.4"},
      {:cowboy, "~> 1.0"},
      {:timex, "~> 3.2.1"},
      {:poison, "~> 2.1", override: true},
      {:httpoison, "~> 0.11.0"},
      {:mailgun, "~> 0.1.2"},
      {:earmark, "~> 1.0.1"},
      {:dogma, "~> 0.1", only: :dev},
      {:mix_test_watch, "~> 0.2.6", only: :dev},
      {:comeonin, "~> 3.0"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:edeliver, "~> 1.6.0"},
      {:exactor, "~> 2.2.4"},
      {:conform, "~> 2.2"}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
