defmodule Mattest.MixProject do
  use Mix.Project

  def project do
    [
      app: :mattest,
      version: "0.1.0",
      elixir: "~> 1.16",
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_clean: ["clean"],
      make_env: %{"MIX_ENV" => to_string(Mix.env())},
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:elixir_make, "~> 0.6"},
      {:benchee, "~> 1.3"}
    ]
  end

  defp aliases do
    [
      bench: "run -e 'Mix.Tasks.Bench.run([])'"
    ]
  end
end
