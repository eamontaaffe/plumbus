defmodule Plumbus.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plumbus,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      name: "Plumbus",
      docs: [
        main: "Plumbus",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Plumbus.Application, []}]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end
end
