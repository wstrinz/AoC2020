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

  def run() do
    File.read!("inputs/day1.txt")
    |> String.split("\n")
    |> Enum.map(&(Integer.parse(&1) |> elem(0)))
    |> find_2020s
  end
end
