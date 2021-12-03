contents =
  File.stream!("./input.txt")
  |> Enum.map(&String.trim(&1))
  |> Enum.map(fn x -> String.split(x, " ") end)
  |> Enum.reduce(%{horz: 0, depth: 0, aim: 0}, fn x, result ->
    case x do
      ["forward", value] ->
        v = String.to_integer(value)

        result
        |> Map.update(:horz, 0, &(&1 + v))
        |> Map.update(:depth, 0, &(&1 + result[:aim] * v))

      ["down", value] ->
        v = String.to_integer(value)

        result
        |> Map.update(:aim, 0, &(&1 + v))

      ["up", value] ->
        v = String.to_integer(value)

        result
        |> Map.update(:aim, 0, &(&1 - v))
    end
  end)

%{:horz => horz, :depth => depth} = contents
IO.inspect(horz * depth)
