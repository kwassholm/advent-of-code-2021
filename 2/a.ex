contents =
  File.stream!("./input.txt")
  |> Enum.map(&String.trim(&1))
  |> Enum.map(fn x -> String.split(x, " ") end)
  |> Enum.reduce(%{horz: 0, depth: 0}, fn x, result ->
    case x do
      ["forward", value] ->
        Map.update(result, :horz, 0, &(&1 + String.to_integer(value)))

      ["down", value] ->
        Map.update(result, :depth, 0, &(&1 + String.to_integer(value)))

      ["up", value] ->
        Map.update(result, :depth, 0, &(&1 - String.to_integer(value)))
    end
  end)

%{:horz => horz, :depth => depth} = contents
IO.inspect(horz * depth)
