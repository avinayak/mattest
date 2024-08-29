defmodule Bench do
  def run_bench do
    # Run the benchmark
    # bench_serial()
    # bench_serial_parallel()
    bench_full()
    :ok
  end

  def bench_serial do
    small_matrix_a = MatGenerator.generate_random_matrix(10, 10)
    small_matrix_b = MatGenerator.generate_random_matrix(10, 10)

    Benchee.run(%{
      "serial / small matrices" => fn ->
        SerialMatMul.multiply(small_matrix_a, small_matrix_b)
      end
    })

    :ok
  end

  def bench_serial_parallel do
    small_matrix_a = MatGenerator.generate_random_matrix(10, 10)
    small_matrix_b = MatGenerator.generate_random_matrix(10, 10)

    medium_matrix_a = MatGenerator.generate_random_matrix(100, 100)
    medium_matrix_b = MatGenerator.generate_random_matrix(100, 100)

    large_matrix_a = MatGenerator.generate_random_matrix(1000, 1000)
    large_matrix_b = MatGenerator.generate_random_matrix(1000, 1000)

    Benchee.run(%{
      "serial / small matrices" => fn ->
        SerialMatMul.multiply(small_matrix_a, small_matrix_b)
      end,
      "parallel / small matrices" => fn ->
        ParallelMatMul.multiply(small_matrix_a, small_matrix_b)
      end,
      "serial / medium matrices" => fn ->
        SerialMatMul.multiply(medium_matrix_a, medium_matrix_b)
      end,
      "serial / large matrices" => fn ->
        SerialMatMul.multiply(large_matrix_a, large_matrix_b)
      end,
      "parallel / medium matrices" => fn ->
        ParallelMatMul.multiply(medium_matrix_a, medium_matrix_b)
      end,
      "parallel / large matrices" => fn ->
        ParallelMatMul.multiply(large_matrix_a, large_matrix_b)
      end
    })

    :ok
  end

  def bench_full do
    medium_matrix_a = MatGenerator.generate_random_matrix(100, 100)
    medium_matrix_b = MatGenerator.generate_random_matrix(100, 100)

    large_matrix_a = MatGenerator.generate_random_matrix(1000, 1000)
    large_matrix_b = MatGenerator.generate_random_matrix(1000, 1000)

    Benchee.run(%{
      "parallel / medium matrices" => fn ->
        ParallelMatMul.multiply(medium_matrix_a, medium_matrix_b)
      end,
      "nif serial / medium matrices" => fn ->
        NifSerialMatMul.multiply(medium_matrix_a, medium_matrix_a)
      end,
      "nif parallel / medium matrices" => fn ->
        NifMatMulMetal.multiply(medium_matrix_a, medium_matrix_b)
      end,
      "parallel / large matrices" => fn ->
        ParallelMatMul.multiply(large_matrix_a, large_matrix_b)
      end,
      "nif serial / large matrices" => fn ->
        NifSerialMatMul.multiply(large_matrix_a, large_matrix_b)
      end,
      "nif parallel / large matrices" => fn ->
        NifMatMulMetal.multiply(large_matrix_a, large_matrix_b)
      end
    })

    :ok
  end
end
