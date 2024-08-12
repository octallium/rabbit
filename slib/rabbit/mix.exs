defmodule Rabbit.MixProject do
  use Mix.Project

  def project do
    [
      app: :rabbit,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Rabbit.Runtime.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.11.3"},
      {:postgrex, "~> 0.19"},
      {:jason, "~> 1.4.4"},
      {:finch, "~> 0.18"},
      {:cloak_ecto, "~> 1.2.0"},
      {:amqp, "~> 3.3"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
