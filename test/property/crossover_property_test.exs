defmodule CrossoverPropertyTest do
  alias Types.Chromosome
  alias Toolbox.Crossover
  alias Utilities.Misc
  use ExUnit.Case
  use ExUnitProperties
  # import Mox

  # setup :verify_on_exit!

  # @tag :skip
  # property "One-Point Crossover maintains the size of the input chromosomes" do
  #   check all(
  #           size <- integer(0..100),
  #           genes1 <- list_of(integer(), length: size),
  #           genes2 <- list_of(integer(), length: size)
  #         ) do
  #     mock =
  #       MiscMock
  #       |> expect(:random, &Misc.random/1)

  #     if size > 0 do
  #       mock
  #       |> expect(:split, &Misc.split/2)
  #       |> expect(:split, &Misc.split/2)
  #     end

  #     parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
  #     parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
  #     [child1, child2] = Crossover.one_point([parent1, parent2], nil)

  #     assert Arrays.size(child1.genes) == size and
  #              Arrays.size(child2.genes) == size
  #   end
  # end

  # @tag :skip
  # property "Two-Point Crossover maintains the size of the input chromosomes" do
  #   check all(
  #           size <- integer(0..100),
  #           genes1 <- list_of(integer(), length: size),
  #           genes2 <- list_of(integer(), length: size)
  #         ) do

  #     MiscMock
  #     |> expect(:get_cut_points, fn s -> {1, div(s, 2)} end)

  #     parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
  #     parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
  #     [child1, child2] = Crossover.two_point([parent1, parent2])

  #     assert Arrays.size(child1.genes) == size and
  #              Arrays.size(child2.genes) == size
  #   end
  # end

  @tag :property
  property "Scattered Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(5..5),
            genes1 <- list_of(float(), length: size),
            genes2 <- list_of(float(), length: size)
          ) do
      # MiscMock
      # |> expect(:random, &Misc.random/0)

      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
      [child1, child2] = Crossover.scattered([parent1, parent2], 1.0)

      assert Arrays.size(child1.genes) == size and
               Arrays.size(child2.genes) == size
    end
  end
end
