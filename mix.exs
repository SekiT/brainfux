defmodule Brainfux.Mixfile do
  use Mix.Project

  @github_url "https://github.com/SekiT/brainfux"

  def project do
    [
      app: :brainfux,
      version: "0.2.2",
      elixir: "~> 1.3",
      name: "Brainfux",
      description: description(),
      package: package(),
      source_url: @github_url,
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
      {:ex_doc  , "~> 0.14.1", only: :dev },
      {:dialyxir, "~> 0.3.5" , only: :dev },
      {:credo   , "~> 0.4.12", only: :dev },
      {:meck    , "~> 0.8.4" , only: :test},
    ]
  end

  defp description do
    """
    Brainfux enables you to define brainfuck function in elixir.
    """
  end

  defp package do
    [
      name: :brainfux,
      licenses: ["WTFPL"],
      maintainers: ["Takaaki Seki"],
      links: %{"GitHub" => @github_url},
    ]
  end
end
