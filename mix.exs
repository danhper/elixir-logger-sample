defmodule LoggerStarter.Mixfile do
  use Mix.Project

  def project do
    [app: :logger_starter,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :hackney]]
  end

  defp deps do
    [{:hackney, "~> 1.5"}]
  end
end
