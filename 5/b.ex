defmodule Matrix do
  use Agent

  defp start_link(matrix_size) do
    Agent.start_link(fn ->
      Map.new(
        0..matrix_size,
        fn y ->
          {y,
           Map.new(0..matrix_size, fn x ->
             {x, 0}
           end)}
        end
      )
    end)
  end

  def create(matrix_size: matrix_size) do
    {:ok, point} = start_link(matrix_size)
    point
  end

  def update_point(matrix, {x, y}) do
    Agent.update(matrix, &put_in(&1[y][x], &1[y][x] + 1))
  end

  def draw_map(matrix, do_draw: do_draw) do
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

defmodule Day5 do
  def read_input() do
    File.stream!("./input.txt")
    |> Enum.map(&String.trim/1)
  end

  def parse_coords(input) do
    String.split(input, ",")
    |> Enum.map(&String.to_integer(&1))
  end

  def main() do
    matrix = Matrix.create(matrix_size: 999)

    read_input()
    |> Enum.map(&String.split(&1, " -> "))
    |> Enum.map(fn [a, b] ->
      [x1, y1, x2, y2] = parse_coords(a) ++ parse_coords(b)
      dy = y2 - y1
      dx = x2 - x1

      cond do
        dx == 0 or dy == 0 ->
          for i <- x1..x2,
              j <- y1..y2,
              do: {i, j}

        abs(dx) == abs(dy) ->
          Enum.zip([Enum.to_list(x1..Enum.sum([x1, dx])), Enum.to_list(y1..Enum.sum([y1, dy]))])

        true ->
          nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.map(fn input ->
      Enum.map(input, fn {x, y} ->
        Matrix.update_point(matrix, {x, y})
      end)
    end)

    Matrix.draw_map(matrix, do_draw: false)
  end
end

Day5.main()
