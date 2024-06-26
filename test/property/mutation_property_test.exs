defmodule MutationPropertyTest do
  alias Types.Chromosome
  alias Toolbox.Mutation
  alias Utilities.Misc
  use ExUnit.Case
  use ExUnitProperties

  property "Full scramble mutation mantains the size of the chromosome and the genes" do
    check all(
            size <- integer(1..100),
            genes <- list_of(integer(), length: size)
          ) do
      chromosome = %Chromosome{genes: genes |> Arrays.new()}
      mutant = Mutation.scramble(chromosome, nil)

      genes_set = MapSet.new(genes)
      mutated_genes_set = MapSet.new(mutant.genes)

      assert genes_set == mutated_genes_set

      assert Arrays.size(mutant.genes) == size
    end
  end

  property "One-gene mutation mantains the size of the chromosome and the genes's bounds" do
    check all(
            size <- integer(1..100),
            lower_bounds <- list_of(integer(-10..0), length: size),
            upper_bounds <- list_of(integer(1..10), length: size)
          ) do
      {l_bounds, u_bounds} = {Arrays.new(lower_bounds), Arrays.new(upper_bounds)}

      genes =
        for index <- 0..(size - 1) do
          range = l_bounds[index]..u_bounds[index]
          Misc.random(range)
        end

      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      mutant = Mutation.one_gene(chromosome, {l_bounds, u_bounds})

      0..(size - 1)
      |> Enum.each(fn index ->
        range = l_bounds[index]..u_bounds[index]
        assert mutant.genes[index] in range
      end)

      assert Arrays.size(mutant.genes) == size
    end
  end

  property "All-genes mutation mantains the size of the chromosome and the genes's bounds" do
    check all(
            size <- integer(1..100),
            lower_bounds <- list_of(integer(-10..0), length: size),
            upper_bounds <- list_of(integer(1..10), length: size)
          ) do
      {l_bounds, u_bounds} = {Arrays.new(lower_bounds), Arrays.new(upper_bounds)}

      genes =
        for index <- 0..(size - 1) do
          range = l_bounds[index]..u_bounds[index]
          Misc.random(range)
        end

      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      mutant = Mutation.all_genes(chromosome, {l_bounds, u_bounds})

      0..(size - 1)
      |> Enum.each(fn index ->
        range = l_bounds[index]..u_bounds[index]
        assert mutant.genes[index] in range
      end)

      assert Arrays.size(mutant.genes) == size
    end
  end

  property "Flip Mutation maintains the size of the chromosome and genes being binary" do
    check all(
            size <- integer(1..100),
            rate <- float(min: 0.0, max: 1.0),
            genes <- list_of(integer(0..1), length: size)
          ) do
      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      mutant = Mutation.flip(chromosome, rate)

      0..(size - 1)
      |> Enum.each(fn index ->
        range = 0..1
        assert mutant.genes[index] in range
      end)

      assert Arrays.size(mutant.genes) == size
    end
  end

  property "Gaussian Mutation maintains the size of the chromosome" do
    check all(
            size <- integer(1..100),
            genes <- list_of(integer(), length: size)
          ) do
      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      mutant = Mutation.gaussian(chromosome)

      assert Arrays.size(mutant.genes) == size
    end
  end

  property "Swap Mutation maintains the size of the chromosome" do
    check all(
            size <- integer(3..100),
            genes <- list_of(integer(), length: size)
          ) do
      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      mutant = Mutation.swap(chromosome)

      assert Arrays.size(mutant.genes) == size
    end
  end

  property "Invert Mutation maintains the size of the chromosome" do
    check all(
            size <- integer(1..100),
            genes <- list_of(integer(), length: size)
          ) do
      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      mutant = Mutation.invert(chromosome)

      assert Arrays.size(mutant.genes) == size
    end
  end
end
