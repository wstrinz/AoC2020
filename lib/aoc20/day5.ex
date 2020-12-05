defmodule Aoc20.Day5 do
  def seat_id_for_boarding_pass(boarding_pass) do
    {row, ""} =
      boarding_pass
      |> String.graphemes()
      |> Enum.slice(0..-4)
      |> Enum.join()
      |> String.replace("B", "1")
      |> String.replace("F", "0")
      |> Integer.parse(2)

    {col, ""} =
      boarding_pass
      |> String.graphemes()
      |> Enum.slice(-3..-1)
      |> Enum.join()
      |> String.replace("R", "1")
      |> String.replace("L", "0")
      |> Integer.parse(2)

    row * 8 + col
  end

  def find_largest_id(seats) do
    seats |> Enum.map(&seat_id_for_boarding_pass/1) |> Enum.sort() |> Enum.reverse() |> Enum.at(0)
  end

  def find_my_seat(seats) do
    ids =
      seats
      |> Enum.map(&seat_id_for_boarding_pass/1)
      |> MapSet.new()

    0..1023
    |> MapSet.new()
    |> MapSet.difference(ids)
    |> Enum.to_list()
    |> Enum.find(fn id ->
      MapSet.member?(ids, id + 1) and MapSet.member?(ids, id - 1)
    end)
  end

  def run() do
    seats = File.read!("inputs/day5.txt") |> String.split("\n")

    part1 = find_largest_id(seats)

    part2 = find_my_seat(seats)

    [part1, part2]
  end
end
