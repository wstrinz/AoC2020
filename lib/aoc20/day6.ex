defmodule Aoc20.Day6 do
  def group_count_all(customs_form) do
    customs_form
    |> String.split("\n")
    |> Enum.map(fn entry ->
      MapSet.new(String.graphemes(entry))
    end)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.size()
  end

  def group_count_any(customs_form) do
    customs_form
    |> String.split("\n")
    |> Enum.flat_map(&String.graphemes/1)
    |> Enum.uniq()
    |> Enum.count()
  end

  def run() do
    customs_forms = File.read!("inputs/day6.txt") |> String.split("\n\n")

    part1 = customs_forms |> Enum.map(&group_count_any/1) |> Enum.sum()

    part2 = customs_forms |> Enum.map(&group_count_all/1) |> Enum.sum()

    [part1, part2]
  end
end
