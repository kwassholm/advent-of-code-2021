defmodule Day5A.Matrix do
  use Agent

  defp start_link() do
    Agent.start_link(fn ->
      Map.new(
        0..999,
        fn y ->
          {y,
           Map.new(0..999, fn x ->
             {x, 0}
           end)}
        end
      )
    end)
  end

  def create() do
    {:ok, point} = start_link()
    point
  end

  def update_point(matrix, {x, y}) do
    Agent.update(matrix, &put_in(&1[y][x], &1[y][x] + 1))
  end

  def draw_map(matrix, do_draw \\ false) do
    Agent.get(matrix, & &1)
    |> Enum.reduce([], fn {_i, row}, acc ->
      count =
        Enum.reduce(row, 0, fn {_i, x}, acc ->
          if do_draw, do: IO.write(" #{x} ")

          case x do
            x when x >= 2 -> acc + 1
            _ -> acc
          end
        end)

      if do_draw, do: IO.puts("")

      [count | acc]
    end)
    |> Enum.sum()
    |> (&IO.puts("Result: #{&1}")).()
  end
end

defmodule Day5A do
  def read_input() do
    File.stream!("#{__DIR__}/input.txt")
    |> Enum.map(&String.trim/1)
  end

  def parse_coords(input) do
    String.split(input, ",")
    |> Enum.map(&String.to_integer(&1))
  end

  def start() do
    matrix = Day5A.Matrix.create()

    read_input()
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.map(fn [a, b] ->
      case parse_coords(a) ++ parse_coords(b) do
        [x1, y1, x2, y2] when x1 == x2 or y1 == y2 ->
          for i <- x1..x2,
              j <- y1..y2,
              do: {i, j}

        _ ->
          nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.map(fn input ->
      Enum.map(input, fn {x, y} ->
        Day5A.Matrix.update_point(matrix, {x, y})
      end)
    end)

    Day5A.Matrix.draw_map(matrix)
  end
end
