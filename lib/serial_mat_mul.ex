defmodule SerialMatMul do
  @moduledoc """
  Serial matrix multiplication
  """

  @doc """
  Multiplies two matrices serially
  ## Examples
  iex> SerialMatMul.multiply([[1, 2, 3], [4, 5, 6], [7, 8, 9], [10, 11, 12]], [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]])
  [[38, 44, 50, 56], [83, 98, 113, 128], [128, 152, 176, 200], [173, 206, 239, 272]]
  """

  def multiply(a, b) do
    rows_a = length(a)
    cols_b = length(Enum.at(b, 0))

    for row_idx <- 0..(rows_a - 1) do
      for col_idx <- 0..(cols_b - 1) do
        row =
          Enum.at(a, row_idx)

        col =
          Enum.map(b, fn x -> Enum.at(x, col_idx) end)

        row
        |> Enum.zip(col)
        |> Enum.map(fn {x, y} -> x * y end)
        |> Enum.sum()
      end
    end
  end
end
