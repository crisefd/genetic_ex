defmodule Crossover do
  require Integer
  alias Types.Chromosome
  alias Types.InvalidCutPointError

  def misc, do: Application.get_env(:genetic, :misc)

  def one_point(parent1, parent2, cut_point \\ -1) do
    num_genes = Arrays.size(parent1.genes)
    cut_point = if cut_point < 0, do: misc().random(0..(num_genes - 1)), else: cut_point

    {{l1, r1}, {l2, r2}} =
      {misc().split(parent1.genes, cut_point), misc().split(parent2.genes, cut_point)}

    {
      %Chromosome{genes: Arrays.concat(l1, r2)},
      %Chromosome{genes: Arrays.concat(l2, r1)}
    }
  end

  def two_point(parent1, parent2) do
    num_genes = Arrays.size(parent1.genes)
    cut_point1 = misc().random(0..(num_genes - 1))
    cut_point2 = misc().random(0..cut_point1)

    if cut_point1 == cut_point2 do
      one_point(parent1, parent2, cut_point1)
    else
      left_range = 0..cut_point1
      mid_range = (cut_point1 + 1)..cut_point2
      right_range = (cut_point2 + 1)..(num_genes - 1)

      {l1, m1, r1} =
        {Arrays.slice(parent1.genes, left_range), Arrays.slice(parent1.genes, mid_range),
         Arrays.slice(parent1.genes, right_range)}

      {l2, m2, r2} =
        {Arrays.slice(parent2.genes, left_range), Arrays.slice(parent2.genes, mid_range),
         Arrays.slice(parent2.genes, right_range)}

      genes1 = l1 |> Arrays.concat(m2) |> Arrays.concat(r1)
      genes2 = l2 |> Arrays.concat(m1) |> Arrays.concat(r2)

      {
        %Chromosome{genes: genes1},
        %Chromosome{genes: genes2}
      }
    end
  end

  def scattered(parent1, parent2) do
    num_genes = Arrays.size(parent1.genes)

    {new_genes1, new_genes2} =
      0..(num_genes - 1)
      |> Enum.reduce({parent1.genes, parent2.genes}, fn index, {genes1, genes2} ->
        coin_flip = misc().random(0..1)

        {gene1, gene2} =
          if coin_flip == 0 do
            {Arrays.get(parent2.genes, index), Arrays.get(parent1.genes, index)}
          else
            {Arrays.get(parent1.genes, index), Arrays.get(parent2.genes, index)}
          end

        {Arrays.replace(genes1, index, gene1), Arrays.replace(genes2, index, gene2)}
      end)

    {
      %Chromosome{genes: new_genes1},
      %Chromosome{genes: new_genes2}
    }
  end

  def arithmetic(parent1, parent2) do
    r_percentage = misc().random(0..10)
    s_percentage = 1.0 - r_percentage
    num_genes = Arrays.size(parent1.genes)

    {child1_genes, child2_genes} =
      0..(num_genes - 1)
      |> Enum.reduce({parent1.genes, parent2.genes}, fn index, {child1_genes, child2_genes} ->
        gene1 = Arrays.get(parent1.genes, index)
        gene2 = Arrays.get(parent2.genes, index)

        new_gene1 = r_percentage * gene1 + s_percentage * gene2
        new_gene2 = s_percentage * gene1 + r_percentage * gene2

        {
          Arrays.replace(child1_genes, index, new_gene1),
          Arrays.replace(child2_genes, index, new_gene2)
        }
      end)

    {
      %Chromosome{genes: child1_genes},
      %Chromosome{genes: child2_genes}
    }
  end
end
