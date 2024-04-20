defmodule MutationTest do
  alias Types.Chromosome
  use ExUnit.Case
  import Mox
  doctest Mutation

  setup :verify_on_exit!

  @base %Chromosome{genes: [1, 2, 3, 4, 5, 6] |> Arrays.new()}
  @allels 0..50

  test "Shuffle Mutation" do
    %Chromosome{genes: base_genes} = @base

    MiscMock
    |> expect(:shuffle, &Misc.shuffle/1)

    %Chromosome{genes: mutated_genes} = Mutation.shuffle(@base)

    mutated_genes_l = mutated_genes |> Arrays.to_list()
    base_genes_l = base_genes |> Arrays.to_list()

    valid_genes =
      mutated_genes_l
      |> Enum.reduce(true, fn mutated_gene, answer ->
        Enum.member?(base_genes_l, mutated_gene) and answer
      end)

    assert valid_genes
    assert base_genes_l !== mutated_genes_l
  end

  test "One-Gene Mutation" do
    num_genes = Arrays.size(@base.genes)

    MiscMock
    |> expect(:random, &Misc.random/1)
    |> expect(:random, &Misc.random/1)

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
    MiscMock
    |> expect(:random, &Misc.random/1)
    |> expect(:random, &Misc.random/1)
    |> expect(:random, &Misc.random/1)
    |> expect(:random, &Misc.random/1)
    |> expect(:random, &Misc.random/1)
    |> expect(:random, &Misc.random/1)

    %Chromosome{genes: mutated_genes} = Mutation.all_genes(@base, @allels)

    valid_genes =
      mutated_genes
      |> Arrays.reduce(true, fn gene, answer ->
        gene in @allels and answer
      end)

    assert valid_genes
    assert mutated_genes !== @base.genes
  end
end
