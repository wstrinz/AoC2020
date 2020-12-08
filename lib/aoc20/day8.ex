defmodule Aoc20.Day8 do
  def exec_line(line, line_pointer, register) do
    [[_, instruction, sign, amount]] = Regex.scan(~r/(\w+) ([+-])(\d+)/, line)

    signed_amount =
      if sign == "-", do: -1 * String.to_integer(amount), else: String.to_integer(amount)

    case instruction do
      "acc" ->
        [line_pointer + 1, register + signed_amount]

      "nop" ->
        [line_pointer + 1, register]

      "jmp" ->
        [line_pointer + signed_amount, register]
    end
  end

  def run_until_loop_or_terminate(instructions, line_pointer, register, line_set) do
    if MapSet.member?(line_set, line_pointer) or line_pointer == length(instructions) do
      [line_pointer, register]
    else
      [next_line_pointer, next_register] =
        exec_line(Enum.at(instructions, line_pointer), line_pointer, register)

      run_until_loop_or_terminate(
        instructions,
        next_line_pointer,
        next_register,
        MapSet.put(line_set, line_pointer)
      )
    end
  end

  def check_permuted_instruction(instructions, {line, index}) do
    [[_, instruction, sign, amount]] = Regex.scan(~r/(\w+) ([+-])(\d+)/, line)

    case instruction do
      "acc" ->
        run_until_loop_or_terminate(instructions, 0, 0, MapSet.new())

      "nop" ->
        List.replace_at(instructions, index, "jmp #{sign}#{amount}")
        |> run_until_loop_or_terminate(0, 0, MapSet.new())

      "jmp" ->
        List.replace_at(instructions, index, "nop #{sign}#{amount}")
        |> run_until_loop_or_terminate(0, 0, MapSet.new())
    end
  end

  def run() do
    instructions = File.read!("inputs/day8.txt") |> String.split("\n")

    part1 = run_until_loop_or_terminate(instructions, 0, 0, MapSet.new())

    {:ok, part2} =
      instructions
      |> Enum.with_index()
      |> Task.async_stream(&check_permuted_instruction(instructions, &1))
      |> Enum.to_list()
      |> Enum.find(fn {:ok, [pointer, _]} -> pointer == length(instructions) end)

    [part1, part2]
  end
end
