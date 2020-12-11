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

  def closest_with_condition(grid, start_x, start_y, condition) do
    closest =
      grid
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        line
        |> Enum.with_index()
        |> Enum.filter(fn {cell, x} ->
          condition.([x, y]) && cell != "."
        end)
        |> Enum.map(fn {cell, x} -> {x, y, cell} end)
      end)
      |> List.flatten()
      |> Enum.sort_by(fn {x, y, _} -> abs(start_x - x) + abs(start_y - y) end)
      |> Enum.at(0)

    case closest do
      {_, _, closest_cell} -> closest_cell
      _ -> closest
    end
  end

  def visible_from(grid, x, y) do
    [
      # left
      fn [cx, cy] -> y == cy && cx < x end,
      # right
      fn [cx, cy] -> y == cy && cx > x end,
      # up
      fn [cx, cy] -> cy < y && cx == x end,
      # down
      fn [cx, cy] -> cy > y && cx == x end,
      # up-left
      fn [cx, cy] -> cy < y && cx < x && abs(x - cx) == abs(y - cy) end,
      # up-right
      fn [cx, cy] -> cy < y && cx > x && abs(x - cx) == abs(y - cy) end,
      # down-left
      fn [cx, cy] -> cy > y && cx < x && abs(x - cx) == abs(y - cy) end,
      # down-right
      fn [cx, cy] -> cy > y && cx > x && abs(x - cx) == abs(y - cy) end
    ]
    |> Enum.map(&closest_with_condition(grid, x, y, &1))
    |> Enum.reject(&is_nil/1)
  end

  def next_cell_state_immediate(grid, cell, x, y) do
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

  def next_cell_state_extended(grid, cell, x, y) do
    if cell == "." do
      "."
    else
      occupied_neighbors =
        visible_from(grid, x, y)
        |> Enum.filter(&(&1 == "#"))
        |> length()

      case cell do
        "#" when occupied_neighbors >= 5 ->
          "L"

        "L" when occupied_neighbors == 0 ->
          "#"

        _ ->
          cell
      end
    end
  end

  def step(grid, update_rule) do
    grid
    |> Enum.with_index()
    |> Task.async_stream(
      fn {line, y} ->
        line
        |> Enum.with_index()
        |> Enum.map(fn {cell, x} ->
          update_rule.(grid, cell, x, y)
        end)
      end,
      max_concurrency: 12
    )
    |> Enum.map(fn {:ok, next_line} -> next_line end)
  end

  def run_until_stable(grid, update_rule) do
    next_grid = step(grid, update_rule)

    print_grid(next_grid)

    if next_grid == grid do
      next_grid
    else
      run_until_stable(next_grid, update_rule)
    end
  end

  def grid_to_string(grid) do
    grid
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
  end

  def print_grid(grid) do
    IO.puts(grid_to_string(grid))
    IO.puts("\n")
    grid
  end

  def save_grid(grid) do
    File.write!("inputs/day11.save.txt", grid_to_string(grid))
  end

  def run() do
    grid =
      File.read!("inputs/day11.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    part1 =
      run_until_stable(grid, &next_cell_state_immediate/4)
      |> Enum.map(fn row -> Enum.count(row, &(&1 == "#")) end)
      |> Enum.sum()

    part2 =
      run_until_stable(grid, &next_cell_state_extended/4)
      |> Enum.map(fn row -> Enum.count(row, &(&1 == "#")) end)
      |> Enum.sum()

    [part1, part2]
  end
end
