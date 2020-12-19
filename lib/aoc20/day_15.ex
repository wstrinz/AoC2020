defmodule Aoc20.Day15 do
  def play_until(end_round, current_round, last_spoken, history) do
    new_history = Map.put(history, last_spoken, current_round - 1)

    spoken =
      case Map.get(history, last_spoken) do
        nil -> 0
        last_spoken when last_spoken == current_round - 1 -> 1
        last_spoken -> current_round - 1 - last_spoken
      end

    # IO.inspect([current_round, last_spoken, spoken, history])

    if end_round == current_round do
      spoken
    else
      play_until(end_round, current_round + 1, spoken, new_history)
    end
  end

  def run() do
    # "9,12,1,4,17,0,18"
    input =
      "9,12,1,4,17,0"
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    starting_speak =
      input
      |> Enum.with_index()
      |> Enum.map(fn {num, idx} ->
        {num, idx + 1}
      end)
      |> Enum.into(%{})

    part1 = play_until(2020, length(input) + 2, 18, starting_speak)

    part2 = "?"

    [part1, part2]
  end
end
