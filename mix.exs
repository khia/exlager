defmodule Exlager.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exlager,
      version: "0.14.1",
      elixir: "> 0.14.0",
      description: description(),
      package: package(),
      source_url: "https://github.com/khia/exlager",
      deps: deps()
    ]
  end

  def application do
    [
      applications: [
        :compiler,
        :syntax_tools,
        :lager
      ],
    ]
  end

  defp deps do
    [
      {:lager, "~> 3.2.4"},
    ]
  end

  defp description() do
    "This package implements a simple Elixir wrapper over basho/lager."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*", "CHANGELOG.md", "package.head.exs"],
      maintainers: ["ILYA Khlopotov"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/khia/exlager"}
    ]
  end
end
