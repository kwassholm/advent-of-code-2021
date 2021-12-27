defmodule Day3A do
  def start() do
    contents =
      File.stream!("#{__DIR__}/input.txt")
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list(&1))
      |> Enum.map(&Enum.map(&1, fn y -> String.to_integer(y) end))
      |> Enum.map(&Enum.sum(&1))
      |> (fn x ->
            gamma =
              Enum.reduce(x, "", fn x, result ->
                cond do
                  x < 500 ->
                    result <> "1"

                  x > 500 ->
                    result <> "0"
                end
              end)

            epsilon =
              Enum.reduce(x, "", fn x, result ->
                cond do
                  x > 500 ->
                    result <> "1"

                  x < 500 ->
                    result <> "0"
                end
              end)

            String.to_integer(gamma, 2) * String.to_integer(epsilon, 2)
          end).()

    IO.inspect(contents)
  end
end
