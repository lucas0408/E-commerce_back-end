defmodule BatchEcommerce.MixProject do
  use Mix.Project

  def project do
    [
      app: :batch_ecommerce,
      version: "0.1.0",
      elixir: "~> 1.18.2",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {BatchEcommerce.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/factories", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.19"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      {:bcrypt_elixir, "~> 3.1.0"},
      {:guardian, "~> 2.3.2"},
      {:credo, "~> 1.7.8", only: [:dev, :test], runtime: false},
      {:ecto_commons, "~> 0.3.4"},
      {:mox, "~> 1.2", only: :test},
      {:hammox, "~> 0.7", only: :test},
      {:ex_aws, "~> 2.5.7"},
      {:ex_aws_s3, "~> 2.5.5"},
      {:hackney, "~> 1.9"},
      {:sweet_xml, "~> 0.7.4"},
      {:mock, "~> 0.3.8"},
      {:uuid, "~> 1.1.8"},
      {:cors_plug, "~> 3.0.3"},
      {:plug_crypto, "~> 2.1.0"},
      {:flop, "~> 0.26.1"},
      {:ex_machina, "~> 2.8.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind batch_ecommerce", "esbuild batch_ecommerce"],
      "assets.deploy": [
        "tailwind batch_ecommerce --minify",
        "esbuild batch_ecommerce --minify",
        "phx.digest"
      ]
    ]
  end
end
