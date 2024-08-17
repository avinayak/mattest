defmodule MattestTest do
  use ExUnit.Case

  test "tests serial mat mul" do
    mat1 = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [10, 11, 12]
    ]

    mat2 = [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [9, 10, 11, 12]
    ]

    result = SerialMatMul.multiply(mat1, mat2)

    assert result == [
             [38, 44, 50, 56],
             [83, 98, 113, 128],
             [128, 152, 176, 200],
             [173, 206, 239, 272]
           ]
  end

  test "tests parallel mat mul" do
    mat1 = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [10, 11, 12]
    ]

    mat2 = [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [9, 10, 11, 12]
    ]

    result = ParallelMatMul.multiply(mat1, mat2)

    assert result == [
             [38, 44, 50, 56],
             [83, 98, 113, 128],
             [128, 152, 176, 200],
             [173, 206, 239, 272]
           ]
  end

  test "tests nif serial mat mul" do
    mat1 = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [10, 11, 12]
    ]

    mat2 = [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [9, 10, 11, 12]
    ]

    result = NifSerialMatMul.multiply(mat1, mat2)

    assert result == [
             [38, 44, 50, 56],
             [83, 98, 113, 128],
             [128, 152, 176, 200],
             [173, 206, 239, 272]
           ]
  end

  test "sum of two numbers" do
    assert NifDemo.add(1, 2) == 3
  end
end
