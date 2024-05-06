defmodule Crossover do
  @moduledoc """
    The Crossover module contains some of the most commonly used crossover strategies for genetic algorithms
  """

  require Integer
  alias Types.Chromosome

  @type chromosome() :: Chromosome.t()

  @spec misc() :: module()
  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  @spec one_point(parent1 :: chromosome(), parent2 :: chromosome(), cut_point :: integer()) ::
          {chromosome(), chromosome()}

  @doc """
    Takes two chromosomes, applies One-Point crossover and returns a tuple containing the two resulting offspring
  """
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

  @spec two_point(parent1 :: chromosome(), parent2 :: chromosome()) ::
          {chromosome(), chromosome()}

  @doc """
    Takes two chromosomes, applies Two-Point crossover and returns a tuple containing the two resulting offspring
  """
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

  @spec scattered(parent1 :: chromosome(), parent2 :: chromosome()) ::
          {chromosome(), chromosome()}
  @doc """
    Takes two chromosomes, applies Scattered (uniform) crossover and returns a tuple containing the two resulting offspring
  """
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

  @spec arithmetic(chromosome(), chromosome()) :: {chromosome(), chromosome()}
  @doc """
     Takes two chromosomes, applies Arithemtic crossover and returns a tuple containing the two resulting offspring
  """
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

  @spec order_one(chromosome(), chromosome()) :: {chromosome(), chromosome()}
  @doc """
    Performs Order One Crossover
  """
  def order_one(parent1, parent2) do
    genes1 = parent1.genes
    genes2 = parent2.genes

    child1_genes = get_order_one_child(genes1, genes2)
    child2_genes = get_order_one_child(genes2, genes1)

    {
      %Chromosome{genes: child1_genes},
      %Chromosome{genes: child2_genes}
    }
  end

  defp get_order_one_child(genes1, genes2) do
    num_genes = Arrays.size(genes1)
    {cut_point1, cut_point2} = get_cut_points(num_genes)
    range = cut_point1..cut_point2
    sliced_genes1 = Arrays.slice(genes1, range)
    blacklist = MapSet.new(sliced_genes1)

    left_over =
      genes2
      |> Enum.filter(fn gene ->
        !MapSet.member?(blacklist, gene)
      end)

    front = for(_ <- 0..(cut_point1 - 1), do: nil) |> Arrays.new()
    middle = sliced_genes1
    back = for(_ <- (cut_point2 + 1)..(num_genes - 1), do: nil) |> Arrays.new()

    initial_child_genes = front |> Arrays.concat(middle) |> Arrays.concat(back)

    {_, child_genes} =
      0..(num_genes - 1)
      |> Enum.reduce({left_over, Arrays.new()}, fn i, {lo, result} ->
        if Enum.empty?(lo) do
          {lo, result}
        else
          if is_nil(initial_child_genes[i]) do
            {tl(lo), Arrays.append(result, hd(lo))}
          else
            {lo, Arrays.append(result, genes1[i])}
          end
        end
      end)

    if Arrays.size(child_genes) != num_genes do
      IO.inspect(cut_point1, label: "Cut Point 1")
      IO.inspect(cut_point2, label: "Cut Point 2")
      IO.inspect(initial_child_genes, label: "Initial child genes")
      IO.inspect(child_genes, label: "Bad child_genes")
      System.halt(0)
    end

    child_genes
  end

  defp get_cut_points(num_genes) do
    cut_point1 = misc().random(1..(num_genes - 2))
    cut_point2 = misc().random(1..(num_genes - 2))

    if cut_point1 != cut_point2 do
      if cut_point1 < cut_point2 do
        {cut_point1, cut_point2}
      else
        {cut_point2, cut_point1}
      end
    else
      get_cut_points(num_genes)
    end
  end
end
