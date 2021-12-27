defmodule Day1B do
  def start() do
    contents =
      File.stream!("#{__DIR__}/input.txt")
      |> Enum.map(&String.to_integer(String.trim(&1)))
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.map(&Enum.sum(&1))
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.count(fn [a, b] -> b > a end)

    # |> Enum.chunk_every(2, 1, :discard)

    # |> IO.inspect(fn [head | tail] -> tail > head end)

    # |> Enum.count(fn [head | tail] -> tail > head end)

    IO.inspect(contents)
  end
end
