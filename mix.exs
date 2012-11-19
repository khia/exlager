defmodule Exlager.Mixfile do
  use Mix.Project

  def project do
   [
    app: :exlager, version: "0.1", deps: deps
   ]
  end

  def application do
     [
      applications: [
        :compiler,
        :syntax_tools,
        :lager
      ],
     mod: {Lager.App, []}
    ]
  end

  defp deps do
    [
     {:lager, %r(.*), git: "https://github.com/basho/lager.git"},
     {:genx, %r(.*), git: "https://github.com/yrashk/genx"}
    ]
  end
end

