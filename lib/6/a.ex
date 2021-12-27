# Original version was a naive implementation that didn't perform well.
# Current version's idea was stolen from work colleague's solution https://github.com/lupari/aoc2021/blob/main/src/main/scala/challenge/Day06.scala

defmodule SeaRegistry do
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    {:reply, :ok, Map.put(state, key, value)}
  end

  @impl true
  def handle_call({:get, name}, _from, state) do
    {:reply, Map.fetch(state, name), state}
  end

  @impl true
  def handle_cast({:create, fishes}, current_fishes) do
    if Map.has_key?(current_fishes, fishes) do
      {:noreply, current_fishes}
    else
      {:ok, sea} = SeaRegistry.start_link()
      {:noreply, Map.put(current_fishes, fishes, sea)}
    end
  end

  def start_link() do
    GenServer.start_link(__MODULE__, :ok)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, fishes) do
    GenServer.cast(server, {:create, fishes})
  end
end

defmodule Sea do
  def get_fishes(sea) do
    {:ok, fishes} = GenServer.call(sea, {:get, "fishes"})
    fishes
  end

  def put_fishes(sea, fishes) do
    GenServer.call(sea, {:put, "fishes", fishes})
  end
end

defmodule Fish do
  use Agent

  def oldify(fish) do
    case fish do
      0 ->
        [8, 6]

      x ->
        x - 1
    end
  end
end

defmodule Day6A do
  def read_input() do
    File.read!("#{__DIR__}/input.txt")
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.group_by(& &1)
    |> Map.map(fn {_, y} -> Enum.count(y) end)
  end

  def start() do
    {:ok, registry} = SeaRegistry.start_link()

    SeaRegistry.create(registry, "fishes")
    {:ok, sea} = SeaRegistry.lookup(registry, "fishes")

    Sea.put_fishes(sea, read_input())

    Enum.map(1..256, fn _ ->
      fishes = Sea.get_fishes(sea)

      f =
        Map.filter(fishes, fn {n, _} -> n > 0 end)
        |> Enum.map(fn {n, v} -> {n - 1, v} end)
        |> Map.new()

      f8 = Map.get(fishes, 0, 0)
      f6 = Map.get(fishes, 7, 0) + f8

      asd =
        Map.merge(f, %{6 => f6})
        |> Map.merge(%{8 => f8})

      Sea.put_fishes(sea, asd)
    end)

    Sea.get_fishes(sea)
    |> Map.values()
    |> Enum.sum()
    |> (&IO.puts("Result: #{&1}")).()
  end
end
