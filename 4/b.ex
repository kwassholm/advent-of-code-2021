defmodule Board do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{board: [], matches: []} end)
  end

  def init_board(board, numbers) do
    Agent.update(board, &Map.put(&1, "numbers", numbers))
    board
  end

  def create(numbers) do
    {:ok, board} = Board.start_link()

    Board.init_board(board, numbers)
  end

  def get_board(board, name) do
    Agent.get(board, &Map.get(&1, name))
  end

  def replace_value(list, number, value) do
    index = Enum.find_index(list, &(&1 == number))

    List.replace_at(list, index, value)
  end

  def mark_found(board, number) do
    numbers = Board.get_board(board, "numbers")

    case Enum.member?(numbers, number) == true do
      true ->
        Agent.update(board, &Map.put(&1, "numbers", Board.replace_value(numbers, number, true)))
        true

      false ->
        false
    end
  end

  def check_rows(board) do
    matches = Board.get_board(board, "numbers")

    matches
    |> Enum.chunk_every(5)
    |> Enum.reduce_while([], fn x, acc ->
      case Enum.all?(x, &(&1 == true)) do
        true -> {:halt, matches}
        false -> {:cont, acc}
      end
    end)
  end

  def check_columns(board) do
    matches = Board.get_board(board, "numbers")

    Enum.reduce_while(0..4, [], fn i, acc ->
      qqq =
        matches
        |> Enum.drop(i)
        |> Enum.take_every(5)

      case Enum.all?(qqq, &(&1 == true)) do
        true ->
          {:halt, matches}

        false ->
          {:cont, acc}
      end
    end)
  end

  def count_score(numbers, current_number) do
    sum =
      Enum.reject(numbers, &(&1 == true))
      |> Enum.sum()

    sum * current_number
  end

  def check(board) do
    Enum.any?([
      !Enum.empty?(Board.check_rows(board)),
      !Enum.empty?(Board.check_columns(board))
    ])
  end
end

defmodule Bingo do
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
      File.stream!("./input.txt")
      |> Enum.map(&String.trim/1)

    %{
      numbers: parse_bingo_numbers(numbers),
      boards: parse_board_data(boards)
    }
  end

  def main() do
    %{numbers: bingo_numbers, boards: board_numbers} = read_input()
    boards = Enum.map(board_numbers, &Board.create(&1))

    [last_board, last_number] =
      Enum.reduce_while(
        bingo_numbers,
        boards,
        fn current_number, boards ->
          boards =
            Enum.reduce_while(boards, boards, fn board, boards ->
              Board.mark_found(board, current_number)

              Board.check(board)
              |> case do
                true ->
                  boards_left = Enum.reject(boards, &(&1 == board))

                  if Enum.count(boards_left) == 0 do
                    {:halt, board}
                  else
                    {:cont, boards_left}
                  end

                false ->
                  {:cont, boards}
              end
            end)

          boards
          |> case do
            x when is_list(x) -> {:cont, boards}
            _ -> {:halt, [boards, current_number]}
          end
        end
      )

    Board.count_score(
      Board.get_board(last_board, "numbers"),
      last_number
    )
  end
end

Bingo.main()
|> IO.inspect()
