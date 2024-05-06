defmodule CrossoverTest do
  alias Types.Chromosome
  use ExUnit.Case
  import Mox
  doctest Crossover

  @parent1 %Chromosome{genes: Arrays.new([0.3, 0.8, -0.8, -0.2, 0.9])}
  @parent2 %Chromosome{genes: Arrays.new([0.3, -0.2, 0.9, -0.5, -0.3])}

  setup :verify_on_exit!

  test "One-Point Crossover in the middle" do
    cut_point = 2
    expected1 = [0.3, 0.8, 0.9, -0.5, -0.3]
    expected2 = [0.3, -0.2, -0.8, -0.2, 0.9]

    MiscMock
    |> expect(:random, fn _ -> cut_point end)
    |> expect(:split, &Misc.split/2)
    |> expect(:split, &Misc.split/2)

    [child1, child2] = Crossover.one_point([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "One-Point Crossover in the 0 margin" do
    cut_point = 0
    expected1 = [0.3, -0.2, 0.9, -0.5, -0.3]
    expected2 = [0.3, 0.8, -0.8, -0.2, 0.9]

    MiscMock
    |> expect(:random, fn _ -> cut_point end)
    |> expect(:split, &Misc.split/2)
    |> expect(:split, &Misc.split/2)

    [child1, child2] = Crossover.one_point([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "One-Point Crossover in the n-1 margin" do
    cut_point = 4
    expected1 = [0.3, 0.8, -0.8, -0.2, -0.3]
    expected2 = [0.3, -0.2, 0.9, -0.5, 0.9]

    MiscMock
    |> expect(:random, fn _ -> cut_point end)
    |> expect(:split, &Misc.split/2)
    |> expect(:split, &Misc.split/2)

    [child1, child2] = Crossover.one_point([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover in the middle" do
    cut_point1 = 1
    cut_point2 = 3
    expected1 = [0.3, 0.8, 0.9, -0.5, 0.9]
    expected2 = [0.3, -0.2, -0.8, -0.2, -0.3]

    MiscMock
    |> expect(:random, fn _ -> cut_point1 end)
    |> expect(:random, fn _ -> cut_point2 end)

    [child1, child2] = Crossover.two_point([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover in the fringes" do
    cut_point1 = 0
    cut_point2 = 4
    expected1 = @parent2.genes |> Arrays.to_list()
    expected2 = @parent1.genes |> Arrays.to_list()

    MiscMock
    |> expect(:random, fn _ -> cut_point1 end)
    |> expect(:random, fn _ -> cut_point2 end)

    [child1, child2] = Crossover.two_point([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Scattered Crossover" do
    expected1 = [0.3, 0.8, 0.9, -0.2, -0.3]
    expected2 = [0.3, -0.2, -0.8, -0.5, 0.9]

    MiscMock
    |> expect(:random, fn -> 0.0 end)
    |> expect(:random, fn -> 1.0 end)
    |> expect(:random, fn -> 0.0 end)
    |> expect(:random, fn -> 1.0 end)
    |> expect(:random, fn -> 0.0 end)

    [child1, child2] = Crossover.scattered([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Arithmetic Crossover" do
    expected1 = [0.3, 0.4, -0.12, -0.32, 0.42]
    expected2 = [0.3, 0.2, 0.22, -0.38, 0.18]
    tolerance = 0.005
    percentage = 0.6

    MiscMock
    |> expect(:random, fn -> percentage end)

    [child1, child2] = Crossover.arithmetic([@parent1, @parent2])
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()

    assertion1 =
      expected1
      |> Enum.zip(actual1)
      |> Enum.map(fn {expected, actual} -> abs(abs(expected) - abs(actual)) < tolerance end)
      |> Enum.reduce(true, fn acceptable?, result -> acceptable? and result end)

    assertion2 =
      expected2
      |> Enum.zip(actual2)
      |> Enum.map(fn {expected, actual} -> abs(abs(expected) - abs(actual)) < tolerance end)
      |> Enum.reduce(true, fn acceptable?, result -> acceptable? and result end)

    assert(assertion1 and assertion2)
  end

  test "Order-One Crossover" do
    parent1 = %Chromosome{genes: [5, 4, 0, 1, 3, 2, 6] |> Arrays.new()}
    parent2 = %Chromosome{genes: [6, 3, 2, 5, 0, 4, 0] |> Arrays.new()}

    expected1 = [6, 5, 0, 1, 3, 2, 4]
    expected2 = [5, 3, 2, 4, 0, 1, 6]

    MiscMock
    |> expect(:random, fn _ -> 2 end)
    |> expect(:random, fn _ -> 5 end)
    |> expect(:random, fn _ -> 1 end)
    |> expect(:random, fn _ -> 2 end)

    [child1, child2] = Crossover.order_one([parent1, parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()

    assert expected1 == actual1
    assert expected2 == actual2
  end
end
