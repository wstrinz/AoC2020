defmodule Aoc20.Day9 do
  def find_first_encoding_error(sequence) do
    sequence
  end

  def run() do
    sequence = File.read!("inputs/day9.txt") |> String.split("\n")

    part1 = find_first_encoding_error(sequence)

    part2 = "?"

    [part1, part2]
  end
end
