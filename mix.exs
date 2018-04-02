defmodule Line.MixProject do
  use Mix.Project

  def project do
    [
      app: :line,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: true,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:websockex, "~> 0.4.0"},
      {:poison, "~> 3.1"}
    ]
  end
end
