
defmodule Mix.Tasks.Bench do
  use Mix.Task

  @shortdoc "Runs the matrix multiplication benchmark"
  def run(_) do
    # Ensure all dependencies are started
    Mix.Task.run("app.start")

    IO.puts "Running matrix multiplication benchmark..."
    Bench.run_bench()
  end
end
