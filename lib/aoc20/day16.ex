defmodule Aoc20.Day16 do
  def run() do
    [rules, your_ticket, nearby_tickets] =
      File.read!("inputs/day16.txt") |> String.split("\n\n", trim: true)

    part1 = rules

    part2 = "?"

    [part1, part2]
  end
end
