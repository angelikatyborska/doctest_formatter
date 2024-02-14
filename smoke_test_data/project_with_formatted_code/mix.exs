defmodule ProjectWithUnformattedCode.MixProject do
  use Mix.Project

  def project do
    [
      app: :project_with_unformatted_code,
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
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
      {:doctest_formatter, path: "../..", runtime: false}
    ]
  end
end
