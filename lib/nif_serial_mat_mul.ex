defmodule NifSerialMatMul do
  @on_load :load_nif

  def load_nif do
    :erlang.load_nif(:code.priv_dir(:mattest) ++ ~c"/nif_mat_mul", 0)
  end

  def multiply(matrix1, matrix2) do
    m = length(matrix1)
    n = length(hd(matrix1))
    p = length(hd(matrix2))

    if length(matrix2) != n do
      raise ArgumentError, "Matrices cannot be multiplied. Dimensions do not match."
    end

    # Validate that all rows have the same length
    unless Enum.all?(matrix1, &(length(&1) == n)) and Enum.all?(matrix2, &(length(&1) == p)) do
      raise ArgumentError, "All rows in each matrix must have the same length"
    end

    # Convert all elements to floats
    matrix1 = Enum.map(matrix1, fn row -> Enum.map(row, & &1) end)
    matrix2 = Enum.map(matrix2, fn row -> Enum.map(row, & &1) end)

    multiply_matrices(m, n, p, matrix1, matrix2)
  end

  def multiply_matrices(_m, _n, _p, _matrix1, _matrix2) do
    raise "NIF multiply_matrices/5 not implemented"
  end
end
