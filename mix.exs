defmodule SituationRoom.MixProject do
  use Mix.Project

  def project do
    [
      app: :situation_room,
      version: "0.1.0",
      elixir: "~> 1.13.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SituationRoom.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.7.2"},
      {:ecto_sql, "~> 3.7.2"},
      {:plug_cowboy, "~> 2.5.2"},
      {:postgrex, "~> 0.16.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp aliases do
    # Alises that auto setup the database when conducting tests
    [
      test: [
        "ecto.create --quiet",
        "ecto.migrate", "test"
      ]
    ]
  end
end
