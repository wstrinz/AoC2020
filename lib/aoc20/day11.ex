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

  def closest_with_condition_recursive(grid, x, y, ray_cache, {direction, condition}) do
    case :ets.lookup(ray_cache, {direction, x, y}) do
      [{_, cell}] ->
        cell

      _ ->
        valid_neighbors =
          neighborhood(x, y)
          |> Enum.map(fn [x, y] -> [[x, y], cell_at(grid, x, y)] end)
          |> Enum.reject(fn [_, cell] -> is_nil(cell) end)
          |> Enum.filter(fn [loc, _] -> condition.([[x, y], loc]) end)

        case [valid_neighbors, valid_neighbors |> Enum.find(fn [_, cell] -> cell != "." end)] do
          [_, [_, cell]] ->
            cell

          [[next_neighbor], _] ->
            [[next_x, next_y], _] = next_neighbor

            found =
              closest_with_condition_recursive(
                grid,
                next_x,
                next_y,
                ray_cache,
                {direction, condition}
              )

            :ets.insert(ray_cache, {{direction, x, y}, found})

            found

          [[], nil] ->
            nil
        end
    end
  end

  def visible_from(grid, sx, sy, ray_cache) do
    [
      left: fn [[x, y], [cx, cy]] -> y == cy && cx < x end,
      right: fn [[x, y], [cx, cy]] -> y == cy && cx > x end,
      up: fn [[x, y], [cx, cy]] -> cy < y && cx == x end,
      down: fn [[x, y], [cx, cy]] -> cy > y && cx == x end,
      up_left: fn [[x, y], [cx, cy]] -> cy < y && cx < x && abs(x - cx) == abs(y - cy) end,
      up_right: fn [[x, y], [cx, cy]] -> cy < y && cx > x && abs(x - cx) == abs(y - cy) end,
      down_left: fn [[x, y], [cx, cy]] -> cy > y && cx < x && abs(x - cx) == abs(y - cy) end,
      down_right: fn [[x, y], [cx, cy]] -> cy > y && cx > x && abs(x - cx) == abs(y - cy) end
    ]
    |> Enum.map(&closest_with_condition_recursive(grid, sx, sy, ray_cache, &1))
    |> Enum.reject(&is_nil/1)
  end

  def next_cell_state_immediate(grid, cell, x, y, _) do
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

  def next_cell_state_extended(grid, cell, x, y, step_num, ray_cache, change_cache) do
    if cell == "." do
      "."
    else
      case :ets.lookup(change_cache, {x, y}) do
        [{_, step}] when step_num - step > 1 ->
          cell

        _ ->
          occupied_neighbors =
            visible_from(grid, x, y, ray_cache)
            |> Enum.filter(&(&1 == "#"))
            |> length()

          case cell do
            "#" when occupied_neighbors >= 5 ->
              :ets.insert(change_cache, {{x, y}, step_num})
              "L"

            "L" when occupied_neighbors == 0 ->
              :ets.insert(change_cache, {{x, y}, step_num})
              "#"

            _ ->
              cell
          end
      end
    end
  end

  def step(grid, update_rule, step_num) do
    grid
    |> Enum.with_index()
    |> Task.async_stream(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {cell, x} ->
        update_rule.(grid, cell, x, y, step_num)
      end)
    end)
    |> Enum.map(fn {:ok, next_line} -> next_line end)
  end

  def run_until_stable(grid, update_rule, ray_cache, step_num) do
    next_grid = step(grid, update_rule, step_num)

    :ets.delete_all_objects(ray_cache)
    # print_grid(next_grid)

    if next_grid == grid do
      next_grid
    else
      run_until_stable(next_grid, update_rule, ray_cache, step_num + 1)
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
    ray_cache = :ets.new(:ray_cache, [:set, :public])
    change_cache = :ets.new(:change_cache, [:set, :public])

    grid =
      File.read!("inputs/day11.txt")
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)

    part1 =
      run_until_stable(grid, &next_cell_state_immediate/5, ray_cache, 0)
      |> Enum.map(fn row -> Enum.count(row, &(&1 == "#")) end)
      |> Enum.sum()

    part2 =
      run_until_stable(
        grid,
        &next_cell_state_extended(&1, &2, &3, &4, &5, ray_cache, change_cache),
        ray_cache,
        0
      )
      |> Enum.map(fn row -> Enum.count(row, &(&1 == "#")) end)
      |> Enum.sum()

    [part1, part2]
  end
end
