defmodule SerialMatMul do
  @moduledoc """
  Documentation for `SerialMatMul`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SerialMatMul.hello()
      :world

  """
  def hello do
    :world
  end

  def multiply(matrix1, matrix2) do
    with cols1 <- length(hd(matrix1)),
         rows2 <- length(matrix2),
         true <- cols1 == rows2 do
      do_multiply(matrix1, transpose(matrix2))
    else
      _ -> raise "Cannot multiply these matrices. Incompatible dimensions."
    end
  end

  defp do_multiply(matrix1, matrix2_transposed) do
    for row <- matrix1 do
      for col <- matrix2_transposed do
        Enum.zip_with(row, col, &(&1 * &2)) |> Enum.sum()
      end
    end
  end

  defp transpose(matrix) do
    matrix |> List.zip() |> Enum.map(&Tuple.to_list/1)
  end
end
