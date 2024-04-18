defmodule CrossoverTest do
  alias Types.Chromosome
  alias Types.InvalidCutPointError
  use ExUnit.Case
  doctest Crossover

  @parent1 %Chromosome{genes: Arrays.new([0.3, 0.8, -0.8, -0.2, 0.9])}
  @parent2 %Chromosome{genes: Arrays.new([0.3, -0.2, 0.9, -0.5, -0.3])}

  test "One-Point Crossover in the middle" do
    cut_point = 2
    expected1 = [0.3, 0.8, 0.9, -0.5, -0.3]
    expected2 = [0.3, -0.2, -0.8, -0.2, 0.9]
    {child1, child2} = Crossover.one_point(@parent1, @parent2, cut_point)
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "One-Point Crossover in the fringes" do
    cut_point = 0
    expected1 = [0.3, -0.2, 0.9, -0.5, -0.3]
    expected2 = [0.3, 0.8, -0.8, -0.2, 0.9]
    {child1, child2} = Crossover.one_point(@parent1, @parent2, cut_point)
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2

    cut_point = 4
    expected1 = [0.3, 0.8, -0.8, -0.2, -0.3]
    expected2 = [0.3, -0.2, 0.9, -0.5, 0.9]
    {child1, child2} = Crossover.one_point(@parent1, @parent2, cut_point)
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover in the middle" do
    cut_points = {1, 3}
    expected1 = [0.3, 0.8, 0.9, -0.5, 0.9]
    expected2 = [0.3, -0.2, -0.8, -0.2, -0.3]
    {child1, child2} = Crossover.two_point(@parent1, @parent2, cut_points)
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover in the fringes" do
    cut_points = {0, 4}
    expected1 = @parent2.genes |> Arrays.to_list()
    expected2 = @parent1.genes |> Arrays.to_list()
    {child1, child2} = Crossover.two_point(@parent1, @parent2, cut_points)
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover with equal cuts" do
    cut_points = {2, 2}
    expected1 = [0.3, 0.8, 0.9, -0.5, -0.3]
    expected2 = [0.3, -0.2, -0.8, -0.2, 0.9]
    {child1, child2} = Crossover.two_point(@parent1, @parent2, cut_points)
    actual1 = child1.genes |> Arrays.to_list()
    actual2 = child2.genes |> Arrays.to_list()
    assert actual1 == expected1
    assert actual2 == expected2
  end

  test "Two-Point Crossover with invalid cuts" do
    assert_raise InvalidCutPointError, fn ->
      cut_points = {4, 2}
      Crossover.two_point(@parent1, @parent2, cut_points)
    end
  end
end
