defmodule Aoc20.Day11 do
  def cell_at(grid, x, y) do
    if y >= 0 and y < length(grid) do
      row = grid |> Enum.at(y)

      if x >= 0 and x < length(row) do
        row |> Enum.at(x)
      end
    end
  end

  def neighborhood(x, y) do
    [
      [x - 1, y - 1],
      [x, y - 1],
      [x + 1, y - 1],
      [x - 1, y],
      [x + 1, y],
      [x - 1, y + 1],
      [x, y + 1],
      [x + 1, y + 1]
    ]
  end

  def next_cell_state(grid, cell, x, y) do
    occupied_neighbors =
      Enum.filter(neighborhood(x, y), fn [nx, ny] ->
        cell_at(grid, nx, ny) == "#"
      end)
      |> length()

    case cell do
      "#" when occupied_neighbors >= 4 ->
        "L"

      "L" when occupied_neighbors == 0 ->
        "#"

      _ ->
        cell
    end
  end

  def step(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} ->
        next_cell_state(grid, cell, x, y)
      end)
    end)
  end

  def run_until_stable(grid) do
    next_grid = step(grid)

    if next_grid == grid do
      next_grid
    else
      run_until_stable(next_grid)
    end
  end

  def print_grid(grid) do
    grid
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()

    IO.puts("\n")
    grid
  end

  def run() do
    grid =
      File.read!("inputs/day11.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    part1 =
      run_until_stable(grid)
      |> Enum.map(fn row -> Enum.count(row, &(&1 == "#")) end)
      |> Enum.sum()

    part2 = "?"

    [part1, part2]
  end
end
