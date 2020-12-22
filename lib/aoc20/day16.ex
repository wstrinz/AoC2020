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

  def rules_match?(ticket, rules) do
    IO.inspect(Enum.at(rules, 0))

    ticket
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {val, index} ->
      matches_rule?(String.to_integer(val), Enum.at(rules, index))
    end)
  end

  def find_rule_assignments(tickets, rules) do
    all_match = tickets |> Enum.all?(&rules_match?(&1, rules))

    if all_match do
      rules
    else
      find_rule_assignments(tickets, Enum.shuffle(rules))
    end
  end

  def run() do
    [rules, your_ticket, nearby_tickets] =
      File.read!("inputs/day16.txt") |> String.split("\n\n", trim: true)

    parsed_rules = rules |> String.split("\n") |> Enum.map(&parse_rule/1)

    part1 =
      nearby_tickets
      |> String.split("\n")
      |> Enum.slice(1..-1)
      |> Enum.map(&get_invalid_field_values(&1, parsed_rules))
      |> List.flatten()
      |> Enum.filter(& &1)
      |> Enum.sum()

    part2 =
      ((nearby_tickets
        |> String.split("\n")
        |> Enum.slice(1..-1)) ++ [your_ticket |> String.split("\n") |> Enum.slice(1..-1)])
      |> List.flatten()
      |> find_rule_assignments(parsed_rules)
      |> Enum.with_index()
      |> Enum.filter(fn {%{name: name}, _} ->
        Regex.match?(~r/^departure/, name)
      end)
      |> Enum.map(fn {_, idx} ->
        your_ticket
        |> String.split("\n")
        |> Enum.at(1)
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.at(idx)
      end)
      |> Enum.sum()

    [part1, part2]
  end
end
