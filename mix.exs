defmodule DoctestFormatter.MixProject do
  use Mix.Project

  def project do
    [
      app: :doctest_formatter,
      version: "0.3.1",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Doctest Formatter",
      source_url: "https://github.com/angelikatyborska/doctest_formatter/",
      description: description(),
      package: package(),
      docs: docs(),
      dialyzer: [plt_add_apps: [:mix]]
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
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "Elixir formatter plugin for doctests."
  end

  defp package() do
    [
      name: "doctest_formatter",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/angelikatyborska/doctest_formatter",
        "Changelog" =>
          "https://github.com/angelikatyborska/doctest_formatter/blob/main/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      assets: "assets",
      extras: [
        "README.md",
        "CHANGELOG.md"
      ]
    ]
  end
end
