defmodule StreamingChunked.MixProject do
  use Mix.Project

  def project do
    [
      app: :streaming_chunked,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:postgrex, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "~> 0.13.4"},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"},
      {:ibrowse, "~>4.4.0"}
    ]
  end
end
