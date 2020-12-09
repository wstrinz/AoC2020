defmodule Aoc20.Day9 do
  def check_value_at(index, window_start, window_end, sequence) do
    number = Enum.at(sequence, index)
    valid_sum_sources = Enum.slice(sequence, window_start..window_end)

    for(i <- valid_sum_sources, j <- valid_sum_sources, i != j, do: [i, j])
    |> Enum.find(fn [i, j] -> i + j == number end)
  end

  def find_first_encoding_error(sequence) do
    window = 25

    sequence
    |> Enum.with_index()
    |> Enum.find(fn {_, index} ->
      if index > window do
        !check_value_at(index, index - window, index - 1, sequence)
      else
        false
      end
    end)
  end

  def run() do
    sequence =
      File.read!("inputs/day9.txt") |> String.split("\n") |> Enum.map(&String.to_integer/1)

    {part1, error_index} = find_first_encoding_error(sequence)

    {:ok, final_sequence} =
      sequence
      |> Enum.slice(0..error_index)
      |> Enum.with_index()
      |> Task.async_stream(fn {_, start_index} ->
        final_index =
          start_index..error_index
          |> Enum.find(fn end_index ->
            part1 ==
              Enum.slice(sequence, start_index..end_index)
              |> Enum.sum()
          end)

        if final_index do
          Enum.slice(sequence, start_index..final_index)
        else
          nil
        end
      end)
      |> Enum.find(fn {:ok, seq} -> seq end)

    part2 =
      (Enum.sort(final_sequence) |> Enum.reverse() |> Enum.at(0)) +
        (Enum.sort(final_sequence) |> Enum.at(0))

    [part1, part2]
  end
end
