defmodule Aoc20.Day2 do
  def parse_line(line) do
  end

  def line_valid?(line) do
    [[_, range_start, range_end, char, target_string]] =
      Regex.scan(~r/(\d)-(\d) (\w): (\w+)/, line)

    true
  end

  def run() do
    File.read!("inputs/day2.txt")
    |> String.split("\n")
    |> Enum.map(&line_valid?/1)
    |> Enum.count(& &1)
  end
end
