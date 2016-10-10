defmodule Brainfux.Mixfile do
  use Mix.Project

  def project do
    [
      app: :brainfux,
      version: "0.2.0",
      elixir: "~> 1.3",
      name: "Brainfux",
      source_url: "https://github.com/SekiT/brainfux",
      deps: deps(),
      docs: [extras: ["README.md"]],
      dialyzer: [plt_add_deps: :transitive],
    ]
  end

  def application do
    [
      applications: []
    ]
  end

  defp deps do
    [
      {:ex_doc  , "~> 0.14.1", only: :dev},
      {:dialyxir, "~> 0.3.5" , only: :dev},
      {:credo   , "~> 0.4.12", only: :dev},
    ]
  end
end
