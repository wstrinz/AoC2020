defmodule Aoc20.Day14 do
  def masked_memory_addresses(masked_mem_address) do
    case :binary.match(masked_mem_address, "X") do
      {_, _} ->
        [
          masked_memory_addresses(String.replace(masked_mem_address, "X", "0", global: false)),
          masked_memory_addresses(String.replace(masked_mem_address, "X", "1", global: false))
        ]

      :nomatch ->
        masked_mem_address
    end
  end

  def masked_mem_value(mask, decimal) do
    value_bits =
      decimal
      |> String.to_integer()
      |> Integer.to_string(2)
      |> String.pad_leading(36, "0")
      |> String.graphemes()

    mask
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {mask_val, idx} ->
      case mask_val do
        "X" ->
          "X"

        _ ->
          if(mask_val == "1" or Enum.at(value_bits, idx) == "1") do
            "1"
          else
            "0"
          end
      end
    end)
    |> Enum.join()
  end

  def process_line_v2(line, mask, memory) do
    if String.slice(line, 0..3) == "mask" do
      [[_, new_mask]] = Regex.scan(~r/mask = (\w+)/, line)
      [new_mask, memory]
    else
      [[_, location, value]] = Regex.scan(~r/mem\[(\d+)\] = (\d+)/, line)

      [
        mask,
        masked_mem_value(mask, location)
        |> masked_memory_addresses
        |> List.flatten()
        |> Enum.map(&{String.to_integer(&1, 2), String.to_integer(value)})
        |> Enum.into(memory)
      ]
    end
  end

  def masked_value(mask, decimal) do
    value_bits =
      decimal
      |> String.to_integer()
      |> Integer.to_string(2)
      |> String.pad_leading(36, "0")
      |> String.graphemes()

    mask
    |> String.graphemes()
    |> Enum.with_index()
    |> Enum.map(fn {mask_val, idx} ->
      case mask_val do
        "X" -> Enum.at(value_bits, idx)
        _ -> mask_val
      end
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  def process_line(line, mask, memory) do
    if String.slice(line, 0..3) == "mask" do
      [[_, new_mask]] = Regex.scan(~r/mask = (\w+)/, line)
      [new_mask, memory]
    else
      [[_, location, value]] = Regex.scan(~r/mem\[(\d+)\] = (\d+)/, line)

      [
        mask,
        Map.put(
          memory,
          location,
          masked_value(mask, value)
        )
      ]
    end
  end

  def run() do
    input = File.read!("inputs/day14.txt") |> String.split("\n")

    [_, memory_v1] =
      input
      |> Enum.reduce(["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", %{}], fn line, [mask, memory] ->
        process_line(line, mask, memory)
      end)

    part1 =
      memory_v1
      |> Map.values()
      |> Enum.sum()

    [_, memory_v2] =
      input
      |> Enum.reduce(["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", %{}], fn line, [mask, memory] ->
        process_line_v2(line, mask, memory)
      end)

    part2 =
      memory_v2
      |> Map.values()
      |> Enum.sum()

    [part1, part2]
  end
end
