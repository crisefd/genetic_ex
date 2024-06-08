defmodule MutationPropertyTest do
  alias Types.Chromosome
  alias Toolbox.Mutation
  alias Utilities.Misc
  use ExUnit.Case
  use ExUnitProperties

  property "Full scramble mutation mantains the size of the chromosome and the genes" do
    check all(
            size <- integer(0..100),
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
            size <- integer(10..10),
            lower_bounds <- list_of(integer(-10..0), length: size),
            upper_bounds <- list_of(integer(1..10), length: size)
          ) do
      {u_bounds, l_bounds} = {Arrays.new(upper_bounds), Arrays.new(lower_bounds)}

      genes =
        for index <- 0..(size - 1) do
          range = l_bounds[index]..u_bounds[index]
          Misc.random(range)
        end

      chromosome = %Chromosome{genes: genes |> Arrays.new()}

      if Enum.count(upper_bounds) == 0 or Enum.count(lower_bounds) == 0 do
        assert_raise RuntimeError, fn ->
          Mutation.one_gene(chromosome, {u_bounds, l_bounds})
        end
      else
        mutant = Mutation.one_gene(chromosome, {u_bounds, l_bounds})

        0..(size - 1)
        |> Enum.each(fn index ->
          range = l_bounds[index]..u_bounds[index]
          assert mutant.genes[index] in range
        end)

        assert Arrays.size(mutant.genes) == size
      end
    end
  end
end
