defmodule Day3B do
  defp get_common(most, least, values) do
    half = Enum.count(values) / 2

    case Enum.sum(values) do
      x when x > half -> most
      x when x < half -> least
      _ -> most
    end
  end

  def get_common(most, least) do
    &get_common(most, least, &1)
  end

  defp get_matching_rows(rows, value, i) do
    Enum.filter(rows, fn row ->
      String.at(row, i) == value
    end)
  end

  def just_do_it(rows, funk) do
    Enum.reduce_while(
      Enum.to_list(0..String.length(Enum.at(rows, 0))),
      rows,
      fn i, acc ->
        if Enum.count(acc) > 1 do
          common_value =
            Enum.map(acc, &String.to_integer(String.at(&1, i)))
            |> funk.()

          c = get_matching_rows(acc, common_value, i)
          {:cont, c}
        else
          {:halt, acc}
        end
      end
    )
  end

  def start() do
    File.stream!("#{__DIR__}/input.txt")
    |> Enum.map(&String.trim(&1))
    |> (fn rows ->
          [oxygen] = Day3B.just_do_it(rows, Day3B.get_common("1", "0"))
          [scrubber] = Day3B.just_do_it(rows, Day3B.get_common("0", "1"))

          String.to_integer(oxygen, 2) * String.to_integer(scrubber, 2)
        end).()
    |> IO.inspect()
  end
end
