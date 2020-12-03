defmodule Aoc20.Day3 do
  def tree_at?(hill, _, y) when y > length(hill), do: false

  def tree_at?(hill, x, y) do
    "#" == hill |> Enum.at(y) |> String.graphemes() |> Stream.cycle() |> Enum.at(x)
  end

  def check_sled([sled_x, sled_y], hill) do
    0..(length(hill) - 1)
    |> Enum.map(&tree_at?(hill, &1 * sled_x, &1 * sled_y))
    |> Enum.count(& &1)
  end

  def run() do
    hill = File.read!("inputs/day3.txt") |> String.split("\n")

    part1 = check_sled([3, 1], hill)

    part2 =
      [
        [1, 1],
        [3, 1],
        [5, 1],
        [7, 1],
        [1, 2]
      ]
      |> Enum.map(&check_sled(&1, hill))
      |> Enum.reduce(&*/2)

    [part1, part2]
  end
end
