defmodule Matchbox.MixProject do
  use Mix.Project

  @source_url "https://github.com/RequisDev/matchbox"
  @version "0.1.0"

  def project do
    [
      app: :matchbox,
      description: "A standardized api for comparing and transforming terms.",
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        doctor: :test,
        coverage: :test,
        dialyzer: :test,
        coveralls: :test,
        "coveralls.lcov": :test,
        "coveralls.json": :test,
        "coveralls.html": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test
      ],
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        plt_ignore_apps: [],
        plt_local_path: "dialyzer",
        plt_core_path: "dialyzer",
        list_unused_filters: true,
        ignore_warnings: ".dialyzer-ignore.exs",
        flags: [:unmatched_returns, :no_improper_lists]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Static Analysis & Code Quality
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false, optional: true},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false, optional: true},
      {:blitz_credo_checks, "~> 0.1", only: [:dev, :test], runtime: false, optional: true},

      # Documentation Tools
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false, optional: true},
      {:doctor, "~> 0.1", only: [:dev, :test], runtime: false, optional: true},

      # Testing & Coverage
      {:excoveralls, "~> 0.1", only: :test, runtime: false, optional: true},
      {:ex_check, "~> 0.1", only: [:dev, :test], runtime: false, optional: true}
    ]
  end

  defp package do
    [
      maintainers: ["Kurt Hogarth"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/cylkdev/matchbox"},
      files: ~w(mix.exs README.md CHANGELOG.md lib)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/cylkdev/matchbox",
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.txt": [title: "License"],
        "README.md": [title: "Readme"]
      ],
      source_url: @source_url,
      source_ref: @version,
      api_reference: false,
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
