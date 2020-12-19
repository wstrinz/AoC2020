defmodule Aoc20.Day12 do
  def go(ship, amount, heading) do
    case heading do
      0 ->
        %{ship | east: Map.get(ship, :east) + amount}

      90 ->
        %{ship | north: Map.get(ship, :north) - amount}

      180 ->
        %{ship | east: Map.get(ship, :east) - amount}

      270 ->
        %{ship | north: Map.get(ship, :north) + amount}
    end
  end

  @spec rotate_waypoint(map, map, integer) :: map
  def rotate_waypoint(ship, waypoint, amount) do
    new_heading = (Map.get(waypoint, :heading) + amount) |> Integer.mod(360)
    %{north: w_north, east: w_east} = waypoint
    %{north: s_north, east: s_east} = ship
    north_off = w_north - s_north
    east_off = w_east - s_east

    case new_heading - Map.get(waypoint, :heading) do
      0 ->
        %{waypoint | east: w_east, north: w_north}

      90 ->
        %{
          waypoint
          | east: Map.get(ship, :east) + north_off,
            north: Map.get(ship, :north) - east_off
        }

      180 ->
        %{
          waypoint
          | east: Map.get(ship, :east) + north_off,
            north: Map.get(ship, :north) - east_off
        }

      270 ->
        %{waypoint | north: Map.get(ship, :north) + amount}
    end
  end

  def move_ship(move, ship) do
    [[_, action, amount]] = Regex.scan(~r/(\w)(\d+)/, move)

    case action do
      "N" ->
        %{ship | north: Map.get(ship, :north) + String.to_integer(amount)}

      "S" ->
        %{ship | north: Map.get(ship, :north) - String.to_integer(amount)}

      "E" ->
        %{ship | east: Map.get(ship, :east) + String.to_integer(amount)}

      "W" ->
        %{ship | east: Map.get(ship, :east) - String.to_integer(amount)}

      "F" ->
        go(ship, String.to_integer(amount), Map.get(ship, :heading))

      "B" ->
        go(ship, -String.to_integer(amount), Map.get(ship, :heading))

      "R" ->
        %{
          ship
          | heading: (Map.get(ship, :heading) + String.to_integer(amount)) |> Integer.mod(360)
        }

      "L" ->
        %{
          ship
          | heading: (Map.get(ship, :heading) - String.to_integer(amount)) |> Integer.mod(360)
        }
    end
  end

  def move_ship_with_waypoint(move, [ship, waypoint]) do
    [[_, action, amount]] = Regex.scan(~r/(\w)(\d+)/, move)

    case action do
      "N" ->
        [
          ship,
          %{waypoint | north: Map.get(waypoint, :north) + String.to_integer(amount)}
        ]

      "S" ->
        [
          ship,
          %{waypoint | north: Map.get(waypoint, :north) - String.to_integer(amount)}
        ]

      "E" ->
        [
          ship,
          %{waypoint | east: Map.get(waypoint, :east) + String.to_integer(amount)}
        ]

      "W" ->
        [
          ship,
          %{waypoint | east: Map.get(waypoint, :east) - String.to_integer(amount)}
        ]

      "F" ->
        %{north: w_north, east: w_east} = waypoint
        %{north: s_north, east: s_east} = ship

        [
          %{
            ship
            | east: s_east + String.to_integer(amount) * w_east,
              north: s_north + String.to_integer(amount) * w_north
          },
          waypoint
        ]

      "R" ->
        %{north: w_north, east: w_east} = waypoint
        angle = -String.to_integer(amount) * :math.pi() / 180

        new_east =
          w_east * :math.cos(angle) -
            w_north * :math.sin(angle)

        new_north =
          w_east * :math.sin(angle) +
            w_north * :math.cos(angle)

        [
          ship,
          %{waypoint | east: round(new_east), north: round(new_north)}
        ]

      "L" ->
        %{north: w_north, east: w_east} = waypoint
        angle = String.to_integer(amount) * :math.pi() / 180

        new_east =
          w_east * :math.cos(angle) -
            w_north * :math.sin(angle)

        new_north =
          w_east * :math.sin(angle) +
            w_north * :math.cos(angle)

        [
          ship,
          %{waypoint | east: round(new_east), north: round(new_north)}
        ]
    end
  end

  def run() do
    moves = File.read!("inputs/day12.txt") |> String.split("\n")

    part1 =
      moves
      |> Enum.reduce(%{east: 0, north: 0, heading: 0}, &move_ship/2)
      |> (fn %{north: north, east: east} -> abs(north) + abs(east) end).()

    part2 =
      moves
      |> Enum.reduce(
        [%{east: 0, north: 0}, %{east: 10, north: 1, heading: 0}],
        fn move, acc ->
          next = move_ship_with_waypoint(move, acc)
          IO.inspect(acc)
          IO.inspect(move)
          IO.inspect(next)
          IO.puts("\n")
          next
        end
      )
      |> (fn [%{north: north, east: east}, _] -> abs(north) + abs(east) end).()

    [part1, part2]
  end
end
