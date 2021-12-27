defmodule Day1A do
  def start() do
    contents =
      File.stream!("#{__DIR__}/input.txt")
      |> Enum.map(&String.to_integer(String.trim(&1)))
      |> Enum.map_reduce(0, fn x, prev -> {x > prev, x} end)
      |> (fn {x, _} -> x end).()
      |> Enum.count(&(&1 == true))

    # |> Enum.chunk_every(2, 1, :discard)
    # |> Enum.count(fn [a, b] -> b > a end)
    # IO.inspect(contents, limit: :infinity)

    IO.inspect(contents - 1, limit: :infinity)
  end
end
