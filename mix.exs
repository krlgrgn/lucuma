defmodule HoldUp.MixProject do
  use Mix.Project

  def project do
    [
      app: :hold_up,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {HoldUp.Application, []},
      extra_applications: [:logger, :runtime_tools, :ex_phone_number, :ex_twilio, :timex]
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
      {:phoenix, "~> 1.4.3"},
      {:phoenix_pubsub, "~> 1.1.2"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.13.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0.2"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:comeonin, "~> 4.1"},
      {:bcrypt_elixir, "~> 0.12"},
      {:countries, "~> 1.5.1"},
      {:ex_phone_number, "~> 0.2.0"},
      {:ex_twilio, "~> 0.7.0"},
      {:gen_stage, "~> 0.14"},
      {:ex_machina, "~> 2.3"},
      {:wallaby, github: "keathley/wallaby", runtime: false, only: [:test, :ci]},
      {:canada, "~> 1.0.1"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:stripity_stripe, "~> 2.4.0"},
      {:timex, "~> 3.5"},
      {:number, "~> 1.0.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test --cover --force"]
    ]
  end
end
