defmodule Aoc20.Day16 do
  def parse_rule(rule) do
    [[_, name, range_a_start, range_a_end, range_b_start, range_b_end]] =
      Regex.scan(~r/(.+): (\d+)-(\d+) or (\d+)-(\d+)/, rule)

    %{
      name: name,
      range_a_start: String.to_integer(range_a_start),
      range_a_end: String.to_integer(range_a_end),
      range_b_start: String.to_integer(range_b_start),
      range_b_end: String.to_integer(range_b_end)
    }
  end

  def matches_rule?(value, %{
        range_a_start: range_a_start,
        range_a_end: range_a_end,
        range_b_start: range_b_start,
        range_b_end: range_b_end
      }) do
    (value >= range_a_start and value <= range_a_end) or
      (value >= range_b_start and value <= range_b_end)
  end

  def is_valid?(ticket, rules) do
    ticket
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.all?(fn value ->
      Enum.any?(rules, &matches_rule?(value, &1))
    end)
  end

  def get_invalid_field_values(ticket, rules) do
    ticket
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reject(fn value ->
      Enum.any?(rules, &matches_rule?(value, &1))
    end)
  end

  def run() do
    [rules, your_ticket, nearby_tickets] =
      File.read!("inputs/day16.txt") |> String.split("\n\n", trim: true)

    parsed_rules = rules |> String.split("\n") |> Enum.map(&parse_rule/1)

    part1 =
      nearby_tickets
      |> String.split("\n")
      |> Enum.slice(1..-1)
      |> Enum.reject(&is_valid?(&1, parsed_rules))
      |> Enum.map(&get_invalid_field_values(&1, parsed_rules))
      |> List.flatten()
      |> Enum.sum()

    part2 = "?"

    [part1, part2]
  end
end
