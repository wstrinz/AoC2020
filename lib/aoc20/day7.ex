defmodule Aoc20.Day7 do
  def bag_count(start_color, rules) do
    case Map.get(rules, start_color) do
      [] ->
        1

      children ->
        1 +
          (children
           |> Enum.map(fn %{"color" => child_color, "count" => child_count} ->
             child_count * bag_count(child_color, rules)
           end)
           |> Enum.sum())
    end
  end

  def leads_to(start_color, rules, target_color) do
    case Map.get(rules, start_color) do
      [] ->
        false

      children ->
        children
        |> Enum.any?(fn %{"color" => child_color} ->
          if child_color == target_color do
            true
          else
            leads_to(child_color, rules, target_color)
          end
        end)
    end
  end

  def parse_rule(bag_rule) do
    [[_, color, contents_string]] = Regex.scan(~r/^(\w+ \w+) bags contain (.+)/, bag_rule)

    parsed_children =
      Regex.scan(~r/(\d+ \w+ \w+) bag/, contents_string)
      |> Enum.map(fn [_, child_rule] ->
        [[_, count, child_color]] = Regex.scan(~r/(\d+) (\w+ \w+)/, child_rule)
        %{"color" => child_color, "count" => String.to_integer(count)}
      end)

    %{"color" => color, "children" => parsed_children}
  end

  def run() do
    bag_rules = File.read!("inputs/day7.txt") |> String.split("\n")

    parsed_rules =
      bag_rules
      |> Enum.map(&parse_rule/1)
      |> Enum.reduce(%{}, fn %{"color" => rule_color, "children" => children}, acc ->
        Map.put(acc, rule_color, children)
      end)

    part1 =
      Map.keys(parsed_rules)
      |> Enum.map(&leads_to(&1, parsed_rules, "shiny gold"))
      |> Enum.count(& &1)

    part2 = bag_count("shiny gold", parsed_rules) - 1

    [part1, part2]
  end
end
