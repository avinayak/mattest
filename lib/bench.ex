defmodule Bench do
  def run_bench do
    # Run the benchmark
    # small_matrix_a = MatGenerator.generate_random_matrix(10, 10)
    # small_matrix_b = MatGenerator.generate_random_matrix(10, 10)

    # medium_matrix_a = MatGenerator.generate_random_matrix(100, 100)
    # medium_matrix_b = MatGenerator.generate_random_matrix(100, 100)

    large_matrix_a = MatGenerator.generate_random_matrix(40, 144)
    large_matrix_b = MatGenerator.generate_random_matrix(144, 40)

    _ =
      Benchee.run(%{
        "serial / large matrices" => fn ->
          SerialMatMul.multiply(large_matrix_a, large_matrix_b)
        end,
        "parallel / large matrices" => fn ->
          ParallelMatMul.multiply(large_matrix_a, large_matrix_b)
        end,
        "nif serial / large matrices" => fn ->
          NifSerialMatMul.multiply(large_matrix_a, large_matrix_b)
        end
      })

    :ok
  end
end
