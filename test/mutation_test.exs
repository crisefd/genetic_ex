defmodule MutationTest do
  alias Types.Chromosome
  use ExUnit.Case
  import Mox
  doctest Mutation

  setup :verify_on_exit!

  @base %Chromosome{genes: [1, 2, 3, 4, 5, 6] |> Arrays.new()}
  @allels 0..50

  test "Full Scramble Mutation" do
    %Chromosome{genes: base_genes} = @base

    MiscMock
    |> expect(:shuffle, &Misc.shuffle/1)

    %Chromosome{genes: mutated_genes} = Mutation.scramble(@base)

    mutated_genes = mutated_genes |> Arrays.to_list()
    base_genes = base_genes |> Arrays.to_list()

    valid_genes =
      mutated_genes
      |> Enum.reduce(true, fn mutated_gene, answer ->
        Enum.member?(base_genes, mutated_gene) and answer
      end)

    assert valid_genes
    assert base_genes !== mutated_genes
  end

  test "Partial Scramble Mutation" do
    %Chromosome{genes: base_genes} = @base
    cut_point1 = 1
    cut_point2 = 4

    MiscMock
    |> expect(:shuffle, &Misc.shuffle/1)
    |> expect(:get_cut_points, fn _ -> {1, 4} end)

    %Chromosome{genes: mutated_genes} = Mutation.scramble(@base, true)

    assert Arrays.size(mutated_genes) == Arrays.size(base_genes)

    base_genes_set = MapSet.new(base_genes)

    valid_mutated_genes =
      mutated_genes
      |> Enum.reduce(true, fn mutated_gene, answer ->
        Enum.member?(base_genes_set, mutated_gene) && answer
      end)

    num_genes = Arrays.size(base_genes)

    assert valid_mutated_genes
    assert base_genes !== mutated_genes

    {leftover_base_genes, left_over_mutated_genes} =
      0..(num_genes - 1)
      |> Enum.reduce({[], []}, fn i, {b_genes, m_genes} ->
        if i in cut_point1..cut_point2 do
          {b_genes, m_genes}
        else
          new_b_genes = [base_genes[i] | b_genes]
          new_m_genes = [mutated_genes[i] | m_genes]
          {new_b_genes, new_m_genes}
        end
      end)

    assert leftover_base_genes == left_over_mutated_genes
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

  test "Flip Mutation 100% rate" do
    binary_base = %Chromosome{genes: [0, 1, 1, 0, 1, 0] |> Arrays.new()}
    expected_genes = [1, 0, 0, 1, 0, 1]

    MiscMock
    |> expect(:random, fn -> 0.5 end)
    |> expect(:random, fn -> 0.4 end)
    |> expect(:random, fn -> 0.9 end)
    |> expect(:random, fn -> 1.0 end)
    |> expect(:random, fn -> 0.1 end)
    |> expect(:random, fn -> 0.2 end)

    %Chromosome{genes: mutated_genes} = Mutation.flip(binary_base)
    actual_genes = Arrays.to_list(mutated_genes)
    assert expected_genes == actual_genes
  end

  test "Flip Mutation 50% rate" do
    binary_base = %Chromosome{genes: [0, 1, 1, 0, 1, 0] |> Arrays.new()}
    expected_genes = [1, 0, 0, 0, 1, 0]

    MiscMock
    |> expect(:random, fn -> 0.5 end)
    |> expect(:random, fn -> 0.4 end)
    |> expect(:random, fn -> 0.1 end)
    |> expect(:random, fn -> 0.6 end)
    |> expect(:random, fn -> 0.8 end)
    |> expect(:random, fn -> 1.0 end)

    %Chromosome{genes: mutated_genes} = Mutation.flip(binary_base, 0.5)
    actual_genes = Arrays.to_list(mutated_genes)
    assert expected_genes == actual_genes
  end

  test "Flip Mutation Exception" do
    binary_base = %Chromosome{genes: [0, 2, 1, 0, 1, 0, 0, 1, 1, 1, 0] |> Arrays.new()}

    MiscMock
    |> expect(:random, fn -> 0.5 end)

    assert_raise RuntimeError, fn ->
      %Chromosome{genes: _mutated_genes} = Mutation.flip(binary_base)
    end
  end

  test "Gaussian Mutation" do
    %Chromosome{genes: base_genes} = @base
    total_size = Arrays.size(base_genes)
    mean = Enum.sum(base_genes) / total_size

    variance =
      base_genes
      |> Arrays.map(fn gene -> (mean - gene) ** 2 end)
      |> Enum.sum()
      |> Kernel./(total_size)

    MiscMock
    |> expect(:random, fn ^mean, ^variance -> 1.5 end)
    |> expect(:random, fn ^mean, ^variance -> 2.6 end)
    |> expect(:random, fn ^mean, ^variance -> 3.7 end)
    |> expect(:random, fn ^mean, ^variance -> 4.8 end)
    |> expect(:random, fn ^mean, ^variance -> 5.9 end)
    |> expect(:random, fn ^mean, ^variance -> 6.0 end)

    %Chromosome{genes: mutated_genes} = Mutation.gaussian(@base)

    expected_genes = [1.5, 2.6, 3.7, 4.8, 5.9, 6.0] |> Arrays.new()

    assert expected_genes == mutated_genes
  end
end
