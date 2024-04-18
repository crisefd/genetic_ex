defmodule Crossover do
  alias Types.Chromosome

  def cut_point(parent1, parent2) do
    parent_genes1 = parent1.genes
    parent_genes2 = parent2.genes
    num_genes = Arrays.size(parent_genes1)
    cut_point = Enum.random(0..(num_genes - 1))
    {new_genes1, new_genes2} =
      cut_point..(num_genes - 1)
      |> Enum.reduce({parent_genes1, parent_genes2}, fn index, {child_genes1, child_genes2} ->
        gene1 = Arrays.get(child_genes1, index)
        gene2 = Arrays.get(child_genes2, index)
        { Arrays.replace(child_genes1, index, gene2), Arrays.replace(child_genes2, index, gene1) }
      end)
    {
      %Chromosome{ genes: new_genes1 },
      %Chromosome{ genes: new_genes2 }
    }
  end

  def one_point(parent1, parent2) do
    num_genes = Arrays.size(parent1.genes)
    cut_point = Enum.random(0..(num_genes - 1))
    {{l1, r1}, {l2, r2}} = { Misc.split(parent1.genes, cut_point), Misc.split(parent2.genes, cut_point) }
    {
      %Chromosome{ genes:  Arrays.concat(l1, r2) },
      %Chromosome{ genes:  Arrays.concat(l2, r1) }
    }
  end

end
