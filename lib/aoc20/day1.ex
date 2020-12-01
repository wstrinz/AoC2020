defmodule Aoc20.Day1 do
  def check_number(number, numbers) do
    case Enum.find(numbers, &(&1 + number == 2020)) do
      nil -> nil
      matched -> number * matched
    end
  end

  def find_2020s(numbers) do
    numbers
    |> Enum.map(&check_number(&1, numbers))
    |> Enum.find(&(&1 != nil))
  end

  def check_triplets(first_number, second_number, numbers) do
    case Enum.find(numbers, &(&1 + first_number + second_number == 2020)) do
      nil -> nil
      matched -> first_number * second_number * matched
    end
  end

  def find_triplet_2020s(numbers) do
    for(i <- numbers, j <- numbers, do: [i, j])
    |> Enum.map(fn [first_number, second_number] ->
      check_triplets(first_number, second_number, numbers)
    end)
    |> Enum.find(&(&1 != nil))
  end

  def run() do
    numbers =
      File.read!("inputs/day1.txt")
      |> String.split("\n")
      |> Enum.map(&(Integer.parse(&1) |> elem(0)))

    part1 =
      numbers
      |> find_2020s

    part2 =
      numbers
      |> find_triplet_2020s

    IO.puts(~s"""
    Part 1 answer: #{part1}
    Part 2 answer: #{part2}
    """)
  end
end
