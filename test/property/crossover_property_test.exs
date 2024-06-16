defmodule CrossoverPropertyTest do
  alias Types.Chromosome
  alias Toolbox.Crossover
  alias Utilities.Misc
  use ExUnit.Case
  use ExUnitProperties

  property "One-Point Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(1..10),
            genes1 <- list_of(integer(), length: size),
            genes2 <- list_of(integer(), length: size)
          ) do
      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
      [child1, child2] = Crossover.one_point([parent1, parent2])

      assert Arrays.size(child1.genes) == size and
               Arrays.size(child2.genes) == size
    end
  end

  property "Two-Point Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(1..10),
            genes1 <- list_of(integer(), length: size),
            genes2 <- list_of(integer(), length: size)
          ) do
      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
      [child1, child2] = Crossover.two_point([parent1, parent2])

      assert Arrays.size(child1.genes) == size and
               Arrays.size(child2.genes) == size
    end
  end

  property "Scattered Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(1..10),
            genes1 <- list_of(integer(), length: size),
            genes2 <- list_of(integer(), length: size)
          ) do
      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
      [child1, child2] = Crossover.scattered([parent1, parent2], 1.0)

      assert Arrays.size(child1.genes) == size and
               Arrays.size(child2.genes) == size
    end
  end

  property "Arithmetic Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(1..10),
            genes1 <- list_of(integer(), length: size),
            genes2 <- list_of(integer(), length: size)
          ) do
      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}
      [child1, child2] = Crossover.arithmetic([parent1, parent2], 1.0)

      assert Arrays.size(child1.genes) == size and
               Arrays.size(child2.genes) == size
    end
  end

  property "Order-one Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(1..10),
            genes1 <- list_of(integer(), length: size),
            genes2 <- list_of(integer(), length: size)
          ) do
      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}

      if size === 0 do
        assert_raise RuntimeError, fn ->
          Crossover.order_one([parent1, parent2])
        end
      else
        [child1, child2] = Crossover.order_one([parent1, parent2])

        assert Arrays.size(child1.genes) == size and
                 Arrays.size(child2.genes) == size
      end
    end
  end

  property "Taguchi Crossover maintains the size of the input chromosomes" do
    check all(
            size <- integer(1..10),
            genes1 <- list_of(integer(), length: size),
            genes2 <- list_of(integer(), length: size)
          ) do
      parent1 = %Chromosome{genes: genes1 |> Arrays.new()}
      parent2 = %Chromosome{genes: genes2 |> Arrays.new()}

      max_num_factors = 16
      taguchi_array = Misc.load_array("L#{max_num_factors}")

      [child] = Crossover.taguchi_crossover([parent1, parent2], taguchi_array, :min)

      Arrays.size(child.genes) === size
    end
  end
end
