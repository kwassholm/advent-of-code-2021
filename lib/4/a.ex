defmodule Day4A.Board do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{board: [], matches: []} end)
  end

  def init_board(board, numbers) do
    Agent.update(board, &Map.put(&1, "numbers", numbers))
    Agent.update(board, &Map.put(&1, "matches", numbers))
    board
  end

  def create(numbers) do
    {:ok, board} = Day4A.Board.start_link()

    Day4A.Board.init_board(board, numbers)
  end

  def get_board(board, name) do
    Agent.get(board, &Map.get(&1, name))
  end

  def replace_value(list, number, value) do
    index =
      Enum.find_index(list, fn x ->
        x == number
      end)

    List.replace_at(list, index, value)
  end

  def mark_found(board, number) do
    numbers = Day4A.Board.get_board(board, "numbers")

    case Enum.member?(numbers, number) == true do
      true ->
        matches = Day4A.Board.get_board(board, "matches")

        Agent.update(
          board,
          &Map.put(&1, "matches", Day4A.Board.replace_value(matches, number, true))
        )

        true

      false ->
        false
    end
  end

  def check_rows(board) do
    matches = Day4A.Board.get_board(board, "matches")

    matches
    |> Enum.chunk_every(5)
    |> Enum.reduce_while([], fn x, acc ->
      case Enum.all?(x, &(&1 == true)) do
        true -> {:halt, matches}
        false -> {:cont, acc}
      end
    end)
  end

  def count_score(numbers, current_number) do
    sum =
      Enum.reject(numbers, &(&1 == true))
      |> Enum.sum()

    sum * current_number
  end
end

defmodule Day4A.Bingo do
  def parse_board_data(input) do
    input
    |> Enum.reject(&(&1 == ""))
    |> Enum.chunk_every(5)
    |> Enum.map(fn x ->
      Enum.map(x, fn xx ->
        String.split(xx, ~r/([^\d])/, trim: true)
        |> Enum.map(&String.to_integer(&1))
      end)
      |> Enum.concat()
    end)
  end

  def parse_bingo_numbers(input) do
    String.split(input, ",")
    |> Enum.map(&String.to_integer(&1))
  end

  def read_input() do
    [numbers, _ | boards] =
      File.stream!("#{__DIR__}/input.txt")
      |> Enum.map(&String.trim/1)

    %{
      numbers: parse_bingo_numbers(numbers),
      boards: parse_board_data(boards)
    }
  end

  def main() do
    %{numbers: bingo_numbers, boards: board_numbers} = read_input()
    boards = Enum.map(board_numbers, &Day4A.Board.create(&1))

    %{winning_board: winning_board, number: number} =
      Enum.reduce_while(bingo_numbers, [], fn number, acc ->
        result =
          Enum.reduce_while(boards, [], fn board, acc2 ->
            Day4A.Board.mark_found(board, number)
            |> case do
              true ->
                result = Day4A.Board.check_rows(board)

                case Enum.any?(result) do
                  true -> {:halt, result}
                  false -> {:cont, acc2}
                end

              false ->
                {:cont, acc2}
            end
          end)

        case Enum.any?(result) do
          true -> {:halt, %{winning_board: result, number: number}}
          false -> {:cont, acc}
        end
      end)

    Day4A.Board.count_score(winning_board, number)
  end
end

defmodule Day4A do
  def start() do
    Day4A.Bingo.main()
    |> IO.inspect()
  end
end
