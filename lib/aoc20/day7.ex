defmodule Aoc20.Day7 do
  def parse_rule(bag_rule) do
    [[_, color]] = Regex.scan(~r/^(\w+ \w+) bags/, bag_rule)

    %{"color" => color, "children" => %{"color" => "adjective red", "count" => 2}}
  end

  def run() do
    bag_rules = File.read!("inputs/day7.txt") |> String.split("\n")

    part1 =
      bag_rules
      |> Enum.map(&parse_rule/1)
      |> Enum.reduce(%{}, fn %{"color" => rule_color, "children" => children}, acc ->
        Map.put(acc, rule_color, children)
      end)

    part2 = "??"

    [part1, part2]
  end
end
