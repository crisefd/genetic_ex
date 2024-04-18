defmodule MutationTest do
  alias Types.Chromosome
  use ExUnit.Case
  doctest Mutation

  @base %Chromosome{genes: [1, 2, 3, 4, 5, 6] |> Arrays.new()}
  @allels 0..50

  test "Shuffle Mutation" do
    %Chromosome{genes: base_genes} = @base
    %Chromosome{genes: mutated_genes} = Mutation.shuffle(@base)
    assert base_genes !== mutated_genes
  end

  test "One-Gene Mutation" do
    num_genes = Arrays.size(@base.genes)
    %Chromosome{genes: mutated_genes} = Mutation.one_gene(@base, @allels)

    diffs =
      0..(num_genes - 1)
      |> Enum.reduce([], fn index, diffs ->
        g1 = @base.genes |> Arrays.get(index)
        g2 = mutated_genes |> Arrays.get(index)

        if g1 !== g2 do
          [g2 | diffs]
        else
          diffs
        end
      end)

    assert Enum.count(diffs) == 1 and hd(diffs) in @allels
  end

  test "All-Genes Mutation" do
    %Chromosome{genes: mutated_genes} = Mutation.all_genes(@base, @allels)
    assert mutated_genes !== @base.genes
  end
end
