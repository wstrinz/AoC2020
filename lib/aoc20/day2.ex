defmodule Aoc20.Day2 do
  def line_valid_part_2?(line) do
    [[_, start_str, end_str, char, target_string]] = Regex.scan(~r/(\d+)-(\d+) (\w): (\w+)/, line)

    at_pos1 =
      char == target_string |> String.graphemes() |> Enum.at(String.to_integer(start_str) - 1)

    at_pos2 =
      char == target_string |> String.graphemes() |> Enum.at(String.to_integer(end_str) - 1)

    (at_pos1 or at_pos2) and not (at_pos1 and at_pos2)
  end

  def line_valid?(line) do
    [[_, start_str, end_str, char, target_string]] = Regex.scan(~r/(\d+)-(\d+) (\w): (\w+)/, line)

    count = target_string |> String.graphemes() |> Enum.frequencies() |> Map.get(char)

    count >= String.to_integer(start_str) && count <= String.to_integer(end_str)
  end

  def run() do
    lines =
      File.read!("inputs/day2.txt")
      |> String.split("\n")

    part1 =
      lines
      |> Enum.map(&line_valid?/1)
      |> Enum.count(& &1)

    part2 =
      lines
      |> Enum.map(&line_valid_part_2?/1)
      |> Enum.count(& &1)

    [part1, part2]
  end
end
