defmodule ParallelMatMul do
  def multiply(matrix1, matrix2) do
    cols2 = length(hd(matrix2))
    transposed_matrix2 = transpose(matrix2)

    matrix1
    |> Task.async_stream(
      fn row ->
        for col <- transposed_matrix2 do
          dot_product(row, col)
        end
      end,
      ordered: true
    )
    |> Enum.map(fn {:ok, row} -> row end)
  end

  defp dot_product(row1, row2) do
    Enum.zip(row1, row2)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  defp transpose(matrix) do
    matrix
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
