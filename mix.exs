defmodule Genetic.MixProject do
  use Mix.Project

  def project do
    [
      app: :genetic,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers() ++ [:yecc, :leex],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Genetic.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:exprof, "~> 0.2.4"},
      {:benchee, "~> 1.3"},
      {:gnuplot, "~> 1.22"},
      {:alex, "~> 0.3.2"},
      {:libgraph, "~> 0.16.0"},
      {:arrays, "~> 2.1"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.1", only: [:test]},
      {:stream_data, "~> 0.5.0", only: [:property_test]}
    ]
  end

  def cli do
    [preferred_envs: ["test.property": :property_test, "test.unit": :test]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]

  defp elixirc_paths(_), do: ["lib"]

  defp aliases() do
    [
      "test.property": [
        fn _ -> System.put_env("MIX_ENV", "property_test") end,
        "test test/property"
      ],
      "test.unit": [
        fn _ -> System.put_env("MIX_ENV", "test") end,
        "test test/unit"
      ]
    ]
  end
end
