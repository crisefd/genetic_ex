defmodule Crossover do
  alias Types.Chromosome
  alias Types.InvalidCutPointError

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

  def two_point(parent1, parent2, cut_points \\ {-1, -1}) do
    num_genes = Arrays.size(parent1.genes)
    {cut_point1, cut_point2} = cut_points
    cut_point1 = if cut_point1 < 0, do: Enum.random(0..(num_genes - 1)), else: cut_point1
    cut_point2 = if cut_point2 < 0, do: Enum.random(0..(num_genes - 1)), else: cut_point2

    if cut_point1 > cut_point2 do
      raise InvalidCutPointError,
        message:
          "Expected cut point 1 to be lower than cut point 2, got: #{cut_point1} > #{cut_point2}"
    end

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
end
