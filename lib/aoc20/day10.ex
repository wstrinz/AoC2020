defmodule Aoc20.Day10 do
  def count_subtree(match, adapters, count_cache, count) do
    remaining = Enum.filter(adapters, &(&1 >= match))

    case :ets.lookup(count_cache, remaining) do
      [{_, subcount}] ->
        subcount

      _ ->
        subcount = count_distinct_arrangements(remaining, count_cache, count)

        :ets.insert(count_cache, {remaining, subcount})

        subcount
    end
  end

  def count_distinct_arrangements(adapters, count_cache, count) do
    start = Enum.at(adapters, 0)
    matching = adapters |> Enum.filter(&Enum.member?([1, 2, 3], &1 - start))

    case matching do
      [] ->
        1

      _ ->
        sums =
          matching
          |> Enum.map(&count_subtree(&1, adapters, count_cache, count))
          |> Enum.sum()

        count + sums
    end
  end

  def joltage_difference_counts(adapters) do
    adapters
    |> Enum.reduce([0, []], fn adapter, [last, diffs] ->
      [adapter, diffs ++ [adapter - last]]
    end)
    |> Enum.at(1)
    |> Enum.frequencies()
  end

  def run() do
    adapters =
      File.read!("inputs/day10.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sort()

    part1 =
      joltage_difference_counts(adapters)
      |> (fn %{1 => ones, 3 => threes} -> ones * (threes + 1) end).()

    count_cache = :ets.new(:count_cache, [:set])

    max_jolts = Enum.sort(adapters) |> Enum.at(-1) |> (&(&1 + 3)).()
    part2 = count_distinct_arrangements([0] ++ adapters ++ [max_jolts], count_cache, 0)

    [part1, part2]
  end
end
