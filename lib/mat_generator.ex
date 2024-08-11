defmodule MatGenerator do
  def generate_random_matrix(rows, cols, min_value \\ 1, max_value \\ 100) do
    for _ <- 1..rows do
      for _ <- 1..cols do
        Enum.random(min_value..max_value)
      end
    end
  end
end
