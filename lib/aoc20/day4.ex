defmodule Aoc20.Day4 do
  def fields_for(passport) do
    passport
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> List.flatten()
    |> Enum.map(&String.split(&1, ":"))
  end

  def field_valid?([name, value]) do
    case name do
      "byr" ->
        case Integer.parse(value) do
          {value, ""} when value >= 1920 and value <= 2002 ->
            true

          _ ->
            false
        end

      "iyr" ->
        case Integer.parse(value) do
          {value, ""} when value >= 2010 and value <= 2020 ->
            true

          _ ->
            false
        end

      "eyr" ->
        case Integer.parse(value) do
          {value, ""} when value >= 2020 and value <= 2030 ->
            true

          _ ->
            false
        end

      "hgt" ->
        case Regex.scan(~r/(\d+)(\w+)/, value) do
          [[_, height, units]] ->
            case [Integer.parse(height), units] do
              [{height_num, ""}, "in"] ->
                height_num >= 59 and height_num <= 76

              [{height_num, ""}, "cm"] ->
                height_num >= 150 and height_num <= 193

              _ ->
                false
            end

          _ ->
            false
        end

      "hcl" ->
        Regex.match?(~r/#[a-f0-9]{6}/, value)

      "ecl" ->
        Enum.member?(["amb", "blu", "brn", "gry", "grn", "hzl", "oth"], value)

      "pid" ->
        Regex.match?(~r/^\d{9}$/, value)

      "cid" ->
        true

      _ ->
        false
    end
  end

  def is_valid_part2?(passport) do
    fields = fields_for(passport)

    counts_valid =
      ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
      |> Enum.map(fn required_field ->
        Enum.count(fields, fn [name, _] -> name == required_field end)
      end)
      |> Enum.all?(&(&1 == 1))

    counts_valid and Enum.all?(fields, &field_valid?/1)
  end

  def is_valid_part1?(passport) do
    fields = fields_for(passport) |> Enum.map(&Enum.at(&1, 0))

    ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
    |> Enum.all?(fn required_field ->
      Enum.member?(fields, required_field)
    end)
  end

  def run() do
    passports = File.read!("inputs/day4.txt") |> String.split("\n\n")

    part1 =
      passports
      |> Enum.map(&is_valid_part1?/1)
      |> Enum.count(& &1)

    part2 =
      passports
      |> Enum.map(&is_valid_part2?/1)
      |> Enum.count(& &1)

    [part1, part2]
  end
end
