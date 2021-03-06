defmodule Aoc20Test do
  use ExUnit.Case
  doctest Aoc20

  test "day1" do
    assert Aoc20.Day1.run() == [858_496, 263_819_430]
  end

  test "day2" do
    assert Aoc20.Day2.run() == [524, 485]
  end

  test "day3" do
    assert Aoc20.Day3.run() == [198, 5_140_884_672]
  end

  test "day4" do
    assert Aoc20.Day4.run() == [170, 103]
  end

  test "day5" do
    assert Aoc20.Day5.run() == [888, 522]
  end

  test "day6" do
    assert Aoc20.Day6.run() == [6809, 3394]
  end

  test "day7" do
    assert Aoc20.Day7.run() == [148, 24867]
  end

  test "day8" do
    assert Aoc20.Day8.run() == [[47, 1501], [636, 509]]
  end

  test "day9" do
    assert Aoc20.Day9.run() == [14_360_655, 1_962_331]
  end

  test "day10" do
    assert Aoc20.Day10.run() == [2450, 32_396_521_357_312]
  end

  test "day11" do
    assert Aoc20.Day11.run() == [2247, 2011]
  end

  test "day12" do
    assert Aoc20.Day12.run() == [439, 12385]
  end

  test "day13" do
    assert Aoc20.Day13.run() == [4135, 640_856_202_464_541]
  end

  test "day14" do
    assert Aoc20.Day14.run() == [9_615_006_043_476, 4_275_496_544_925]
  end

  test "day15" do
    assert Aoc20.Day15.run() == [610, 1407]
  end

  test "day16" do
    assert Aoc20.Day16.run() == [32842, "?"]
  end
end
