defmodule Crossover do
  alias Types.Chromosome

  def one_point(parent1, parent2, cut_point \\ -1) do
    num_genes = Arrays.size(parent1.genes)
    cut_point = if cut_point < 0, do: Enum.random(0..(num_genes - 1)), else: cut_point

    {{l1, r1}, {l2, r2}} =
      {Misc.split(parent1.genes, cut_point), Misc.split(parent2.genes, cut_point)}

    {
      %Chromosome{genes: Arrays.concat(l1, r2)},
      %Chromosome{genes: Arrays.concat(l2, r1)}
    }
  end
end
