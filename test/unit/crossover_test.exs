defmodule CrossoverTest do
  alias Types.Chromosome
  alias Toolbox.Crossover
  alias Utilities.Misc
  use ExUnit.Case
  import Mox
  doctest Crossover

  @parent1 %Chromosome{genes: Arrays.new([0.3, 0.8, -0.8, -0.2, 0.9])}
  @parent2 %Chromosome{genes: Arrays.new([0.3, -0.2, 0.9, -0.5, -0.3])}

  setup :verify_on_exit!

  test "One-Point Convex Combination Crossover in the middle" do
    cut_point = 2
    expected1 = [0.3, 0.8, 1.0, -0.5, -0.3]
    expected2 = [0.3, -0.2, 0.9000000000000001, -0.2, 0.9]

    bounds = {
      for(_ <- 0..4, do: -1.0) |> Arrays.new(),
      for(_ <- 0..4, do: 1.0) |> Arrays.new()
    }

    MiscMock
    |> expect(:random, fn _ -> cut_point end)
    |> expect(:random, fn 0..10 -> 10 end)
    |> expect(:split, &Misc.split/2)
    |> expect(:split, &Misc.split/2)

    [child1, child2] = Crossover.convex_one_point([@parent1, @parent2], bounds)

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

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

  test "One-Point Crossover exception" do
    assert_raise RuntimeError, fn ->
      Crossover.one_point([])
    end
  end

  test "Two-Point Crossover in the middle" do
    cut_point1 = 1
    cut_point2 = 3
    expected1 = [0.3, 0.8, 0.9, -0.5, 0.9]
    expected2 = [0.3, -0.2, -0.8, -0.2, -0.3]

    MiscMock
    |> expect(:get_cut_points, fn _ -> {cut_point1, cut_point2} end)

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
    |> expect(:get_cut_points, fn _ -> {cut_point1, cut_point2} end)

    [child1, child2] = Crossover.two_point([@parent1, @parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover exception" do
    assert_raise RuntimeError, fn ->
      Crossover.two_point([])
    end
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

  test "Scattered Crossover exception" do
    assert_raise RuntimeError, fn ->
      Crossover.scattered([])
    end
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

  test "Arithmetic Crossover exception" do
    assert_raise RuntimeError, fn ->
      Crossover.arithmetic([])
    end
  end

  test "Order-One Crossover" do
    parent1 = %Chromosome{genes: [5, 4, 0, 1, 3, 2, 6] |> Arrays.new()}
    parent2 = %Chromosome{genes: [6, 3, 2, 5, 0, 4, 0] |> Arrays.new()}

    expected1 = [6, 5, 0, 1, 3, 2, 4]
    expected2 = [5, 3, 2, 4, 0, 1, 6]

    MiscMock
    |> expect(:get_cut_points, fn _ -> {2, 5} end)
    |> expect(:get_cut_points, fn _ -> {1, 2} end)

    [child1, child2] = Crossover.order_one([parent1, parent2])

    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()

    assert expected1 == actual1
    assert expected2 == actual2
  end

  test "Order-One Crossover exception" do
    assert_raise RuntimeError, fn ->
      Crossover.order_one([])
    end
  end

  test "Taguchi Crossover with binary genes" do
    parent1 = %Chromosome{genes: Arrays.new([1, 1, 1, 1, 0, 0, 0])}
    parent2 = %Chromosome{genes: Arrays.new([0, 0, 0, 0, 1, 1, 1])}
    max_num_factors = 8
    taguchi_array = Misc.load_array("L#{max_num_factors}")

    [child] = Crossover.taguchi_crossover([parent1, parent2], taguchi_array, :min)

    %Chromosome{genes: actual_genes} = child
    expected_genes = Arrays.new([0, 0, 0, 0, 0, 0, 0])

    assert expected_genes == actual_genes
  end

  test "Taguchi Crossover with integer genes" do
    parent1 = %Chromosome{genes: Arrays.new([1, 2, 0, 2, 3])}
    parent2 = %Chromosome{genes: Arrays.new([-3, 2, -1, 4, 2])}
    max_num_factors = 8
    taguchi_array = Misc.load_array("L#{max_num_factors}")

    [child] = Crossover.taguchi_crossover([parent1, parent2], taguchi_array, :min)

    %Chromosome{genes: actual_genes} = child
    expected_genes = Arrays.new([1, 2, 0, 2, 2])

    assert expected_genes == actual_genes
  end
end
