defmodule Aoc20.Day10 do
  def run() do
    adapters =
      File.read!("inputs/day10.txt") |> String.split("\n") |> Enum.map(&String.to_integer/1)

    part1 = "?"
    part2 = "?"

    [part1, part2]
  end
end
