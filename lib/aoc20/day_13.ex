defmodule Aoc20.Day13 do
  def find_earliest_bus_after(target, bus_num) do
    {bus_num, target - Integer.mod(target, bus_num) + bus_num}
  end

  def is_magic_sequence(timestamp, busses) do
    IO.puts(timestamp)

    busses
    |> Enum.slice(1..-1)
    |> Enum.all?(fn {bus, idx} ->
      idx ==
        elem(find_earliest_bus_after(timestamp, bus), 1) - timestamp
    end)
  end

  # def extended_gcd(a, b):
  # """Extended Greatest Common Divisor Algorithm

  # Returns:
  #     gcd: The greatest common divisor of a and b.
  #     s, t: Coefficients such that s*a + t*b = gcd

  # Reference:
  #     https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm#Pseudocode
  # """
  # old_r, r = a, b
  # old_s, s = 1, 0
  # old_t, t = 0, 1
  # while r:
  #     quotient, remainder = divmod(old_r, r)
  #     old_r, r = r, remainder
  #     old_s, s = s, old_s - quotient * s
  #     old_t, t = t, old_t - quotient * t

  # return old_r, old_s, old_t

  # def combine_phased_rotations(a_period, a_phase, b_period, b_phase):
  #   """Combine two phased rotations into a single phased rotation

  #   Returns: combined_period, combined_phase

  #   The combined rotation is at its reference point if and only if both a and b
  #   are at their reference points.
  #   """
  #   gcd, s, t = extended_gcd(a_period, b_period)
  #   phase_difference = a_phase - b_phase
  #   pd_mult, pd_remainder = divmod(phase_difference, gcd)
  #   if pd_remainder:
  #       raise ValueError("Rotation reference points never synchronize.")

  #   combined_period = a_period // gcd * b_period
  #   combined_phase = (a_phase - s * pd_mult * a_period) % combined_period
  #   return combined_period, combined_phase

  def combined_phased_rotations(a_period, a_phase, b_period, b_phase) do
    [gcd, s, _] = extended_gcd(a_period, b_period)
    phase_difference = b_phase
    z = div(phase_difference, gcd)
    pd_remainder = rem(phase_difference, gcd)
    m = z * s

    # IO.puts(b_phase)
    # IO.puts(gcd)
    # IO.puts(s)
    # IO.puts(m)

    # IO.puts(b_period)

    # combined_period
    lcm = div(a_period * b_period, gcd)

    if pd_remainder != 0 do
      "no can do"
    else
      [
        Integer.mod(m * a_period, lcm),
        lcm
        # Integer.mod(a_phase - s * pd_mult * a_period, combined_period)
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

  # def arrow_alignment(red_len, green_len, advantage):
  #   """Where the arrows first align, where green starts shifted by advantage"""
  #   period, phase = combine_phased_rotations(
  #       red_len, 0, green_len, -advantage % green_len
  #   )
  #   return -phase % period

  def align_time(bus_a, bus_b, b_offset) do
    [phase, period] = combined_phased_rotations(bus_a, 0, bus_b, Integer.mod(b_offset, bus_b))

    IO.puts(phase)
    IO.puts(period)

    # Integer.mod(-phase, period)
    phase
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

    start_number = 100_002_890_189_425
    # start_number = 7

    part2 =
      Stream.iterate(start_number, &(&1 + elem(Enum.at(indexed_busses, 0), 0)))
      |> Enum.find(fn timestamp ->
        is_magic_sequence(timestamp, indexed_busses)
      end)

    # 0..15
    # |> Enum.map(fn slice ->
    #   slice_start = start_number + slice * 100_000

    #   Task.async(fn ->
    #     try do
    #       Stream.iterate(slice_start, &(&1 + elem(Enum.at(indexed_busses, 0), 0)))
    #       |> Enum.find(fn timestamp ->
    #         if timestamp > start_number * (slice + 1) * 100_000 do
    #           raise "nope"
    #         else
    #           is_magic_sequence(timestamp, indexed_busses)
    #         end
    #       end)
    #     rescue
    #       _ -> "nothing"
    #     end
    #   end)
    # end)
    # |> Enum.map(&Task.await/1)

    [part1, part2]
  end
end
