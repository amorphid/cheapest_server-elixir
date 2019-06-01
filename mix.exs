defmodule CheapestServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :cheapest_server,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CheapestServer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Gen module wrappers
      {:gin, "~> 0.2"},
      # HTTP library
      {:httpoison, "~> 1.5"},
      # JSON codec
      {:json_momoa, "~> 0.1.0"},
    ]
  end
end
