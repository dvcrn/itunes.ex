defmodule Itunes.Mixfile do
  use Mix.Project

  def project do
    [app: :itunes,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
     {:httpoison, "~> 0.8.0"},
     {:poison, "~> 2.0"}
    ]
  end

  defp description do
    """
    iTunes search API wrapper
    """
  end

  defp package do
    [name: :itunes,
     files: ["lib", "config", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["David Mohl"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/dvcrn/itunes.ex"}]
  end
end
