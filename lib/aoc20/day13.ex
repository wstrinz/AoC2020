defmodule Aoc20.Day13 do
  def find_earliest_bus_after(target, bus_num) do
    {bus_num, target - Integer.mod(target, bus_num) + bus_num}
  end

  def combined_phased_rotations(a_period, a_phase, b_period, b_phase) do
    [gcd, s, _] = extended_gcd(a_period, b_period)
    phase_difference = a_phase - b_phase
    z = div(phase_difference, gcd)
    pd_remainder = rem(phase_difference, gcd)
    m = z * s

    lcm = div(a_period * b_period, gcd)

    if pd_remainder != 0 do
      "no can do"
    else
      [
        Integer.mod(-m * a_period + a_phase, lcm),
        lcm
      ]
    end
  end

  def extended_gcd_helper(old_r, old_s, old_t, r, s, t) do
    if r == 0 do
      [old_r, old_s, old_t]
    else
      quotient = div(old_r, r)
      remainder = rem(old_r, r)

      [old_r, r] = [r, remainder]
      [old_s, s] = [s, old_s - quotient * s]
      [old_t, t] = [t, old_t - quotient * t]

      extended_gcd_helper(old_r, old_s, old_t, r, s, t)
    end
  end

  def extended_gcd(a, b) do
    [old_r, r] = [a, b]
    [old_s, s] = [1, 0]
    [old_t, t] = [0, 1]

    extended_gcd_helper(old_r, old_s, old_t, r, s, t)
  end

  def combine_all_phases(initial_phase, inital_period, busses) do
    busses
    |> Enum.reduce([initial_phase, inital_period], fn {bus, idx}, [last_phase, last_period] ->
      combined_phased_rotations(last_period, last_phase, bus, Integer.mod(-idx, bus))
    end)
  end

  def run() do
    [target, busses] = File.read!("inputs/day13.txt") |> String.split("\n")

    {earliest_bus, departs_at} =
      busses
      |> String.split(",")
      |> Enum.reject(fn n -> n == "x" end)
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(&find_earliest_bus_after(String.to_integer(target), &1))
      |> Enum.sort_by(fn {_, earliest_departure} -> earliest_departure end)
      |> Enum.at(0)

    part1 = (departs_at - String.to_integer(target)) * earliest_bus

    indexed_busses =
      busses
      |> String.split(",")
      |> Enum.with_index()
      |> Enum.reject(fn {n, _} -> n == "x" end)
      |> Enum.map(fn {n, idx} -> {String.to_integer(n), idx} end)

    {initial_period, _} = Enum.at(indexed_busses, 0)
    {next_period, next_offset} = Enum.at(indexed_busses, 1)

    [phase, period] =
      combined_phased_rotations(
        initial_period,
        0,
        next_period,
        Integer.mod(-next_offset, next_period)
      )

    [part2, _] = combine_all_phases(phase, period, Enum.slice(indexed_busses, 2..-1))

    [part1, part2]
  end
end
