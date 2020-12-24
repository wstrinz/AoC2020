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
    ticket
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.map(fn {val, index} ->
      matches_rule?(String.to_integer(val), Enum.at(rules, index))
    end)
  end

  def error_count(tickets, rules) do
    tickets
    |> Enum.map(fn ticket ->
      ticket
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.reject(fn {val, index} ->
        matches_rule?(val, Enum.at(rules, index))
      end)
      |> Enum.count()
    end)
    |> List.flatten()
    |> Enum.sum()
  end

  def find_rule_assignments(tickets, rules) do
    if tickets |> Enum.map(&rules_match?(&1, rules)) |> List.flatten() |> Enum.all?() do
      rules
    else
      names = rules |> Enum.map(fn %{name: name} -> name end)
      IO.puts("Checked #{names}")
      find_rule_assignments(tickets, Enum.shuffle(rules))
    end
  end

  def hillclimb_find_assignments(tickets, path, rules) do
    [current_rule | candidate_rules] = rules

    initial_error = error_count(tickets, path ++ rules)

    if initial_error == 0 do
      path ++ rules
    else
      best_candidate =
        candidate_rules
        |> Enum.map(fn candidate ->
          other_rules = candidate_rules |> Enum.filter(&(&1 != candidate))
          candidate_path = path ++ [current_rule, candidate] ++ other_rules
          {candidate, error_count(tickets, candidate_path), other_rules}
        end)
        |> Enum.sort_by(fn {_, err, _} -> err end)
        |> Enum.at(0)

      cond do
        is_nil(best_candidate) ->
          IO.puts("restart at #{initial_error}")

          hillclimb_find_assignments(tickets, [], (path ++ rules) |> Enum.shuffle())

        elem(best_candidate, 1) == 0 ->
          path ++ [current_rule, elem(best_candidate, 0)] ++ elem(best_candidate, 2)

        elem(best_candidate, 1) <= initial_error ->
          hillclimb_find_assignments(
            tickets,
            path ++ [current_rule],
            [elem(best_candidate, 0)] ++ elem(best_candidate, 2)
          )

        true ->
          IO.puts("restart at #{initial_error}")
          hillclimb_find_assignments(tickets, [], (path ++ rules) |> Enum.shuffle())
      end
    end

    # if tickets |> Enum.map(&rules_match?(&1, rules)) |> List.flatten() |> Enum.all?() do
    #   rules
    # else
    #   names = rules |> Enum.map(fn %{name: name} -> name end)
    #   IO.puts("Checked #{names}")
    #   find_rule_assignments(tickets, Enum.shuffle(rules))
    # end
  end

  # def search_rule_tree(tickets, current_rules, remaining_rules, cache) do
  #   [start_rule | other_rules] = rules
  # end

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

    valid_tickets =
      ((nearby_tickets
        |> String.split("\n")
        |> Enum.slice(1..-1)) ++ [your_ticket |> String.split("\n") |> Enum.slice(1..-1)])
      |> List.flatten()
      |> Enum.filter(fn ticket ->
        ticket
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.all?(fn value ->
          Enum.any?(parsed_rules, &matches_rule?(value, &1))
        end)
      end)

    part2 =
      valid_tickets
      |> hillclimb_find_assignments([], parsed_rules)

    # |> Enum.with_index()
    # |> Enum.filter(fn {%{name: name}, _} ->
    #   Regex.match?(~r/^departure/, name)
    # end)
    # |> Enum.map(fn {_, idx} ->
    #   your_ticket
    #   |> String.split("\n")
    #   |> Enum.at(1)
    #   |> String.split(",")
    #   |> Enum.map(&String.to_integer/1)
    #   |> Enum.at(idx)
    # end)
    # |> Enum.sum()

    # part2 = parsed_rules |> Enum.map(fn %{name: name} -> name end) |> Aoc20.Permutations.of()

    [part1, part2]
  end
end
