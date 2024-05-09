defmodule Toolbox.Crossover do
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

  @spec one_point(parents :: list(chromosome()), cut_point :: integer()) ::
          list(chromosome())

  def one_point(parents, cut_point \\ -1)

  def one_point([], _), do: raise("The list of parents cannot be empty")

  def one_point([_parent | []] = parents, _), do: parents

  @doc """
    Takes two chromosomes, applies One-Point crossover and returns a tuple containing the two resulting offspring
  """
  def one_point(parents, cut_point) do
    num_genes = Arrays.size(hd(parents).genes)
    cut_point = if cut_point < 0, do: misc().random(0..(num_genes - 1)), else: cut_point

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      {{l1, r1}, {l2, r2}} =
        {misc().split(parent1.genes, cut_point), misc().split(parent2.genes, cut_point)}

      child1 = %Chromosome{genes: Arrays.concat(l1, r2)}
      child2 = %Chromosome{genes: Arrays.concat(l2, r1)}

      [child1, child2 | childs]
    end)
  end

  @spec two_point(parents :: list(chromosome())) ::
          list(chromosome())

  def two_point([]), do: raise("The list of parents cannot be empty")

  def two_point([_parent | []] = parents), do: parents

  @doc """
    Takes two chromosomes, applies Two-Point crossover and returns a tuple containing the two resulting offspring
  """
  def two_point(parents) do
    num_genes = Arrays.size(hd(parents).genes)
    {cut_point1, cut_point2} = misc().get_cut_points(num_genes)

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
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

      child1 = %Chromosome{genes: genes1}
      child2 = %Chromosome{genes: genes2}

      [child1, child2 | childs]
    end)
  end

  @spec scattered(parents :: list(chromosome()), rate :: float()) ::
          list(chromosome())

  @doc """
    Takes two chromosomes, applies Scattered (uniform) crossover and returns a tuple containing the two resulting offspring
  """
  def scattered(parents, rate \\ 0.5)

  def scattered([], _), do: raise("The list of parents cannot be empty")

  def scattered([_parent | []] = parents, _), do: parents

  def scattered(parents, rate) do
    num_genes = Arrays.size(hd(parents).genes)

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      {new_genes1, new_genes2} =
        0..(num_genes - 1)
        |> Enum.reduce({parent1.genes, parent2.genes}, fn index, {genes1, genes2} ->
          coin_flip = misc().random()

          {gene1, gene2} =
            if coin_flip <= rate do
              {Arrays.get(parent2.genes, index), Arrays.get(parent1.genes, index)}
            else
              {Arrays.get(parent1.genes, index), Arrays.get(parent2.genes, index)}
            end

          {Arrays.replace(genes1, index, gene1), Arrays.replace(genes2, index, gene2)}
        end)

      child1 = %Chromosome{genes: new_genes1}
      child2 = %Chromosome{genes: new_genes2}
      [child1, child2 | childs]
    end)
  end

  @spec arithmetic(parents :: list(chromosome()), percentage :: float()) ::
          list(chromosome())
  @doc """
     Takes two chromosomes, applies Arithemtic crossover and returns a tuple containing the two resulting offspring
  """
  def arithmetic(parents, percentage \\ 0.0)

  def arithmetic([], _), do: raise("The list of parents cannot be empty")

  def arithmetic([_parent | []] = parents, _), do: parents

  def arithmetic(parents, percentage) do
    r_percentage = if percentage == 0.0, do: misc().random(), else: percentage
    s_percentage = 1.0 - r_percentage
    num_genes = Arrays.size(hd(parents).genes)

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
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

      child1 = %Chromosome{genes: child1_genes}
      child2 = %Chromosome{genes: child2_genes}
      [child1, child2 | childs]
    end)
  end

  @spec order_one(parents :: list(chromosome())) :: list(chromosome())

  def order_one([]), do: raise("The list of parents cannot be empty")

  def order_one([_parent | []] = parents), do: parents

  @doc """
    Performs Order One Crossover
  """
  def order_one(parents) do
    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      genes1 = parent1.genes
      genes2 = parent2.genes

      child1_genes = get_order_one_child(genes1, genes2)
      child2_genes = get_order_one_child(genes2, genes1)

      child1 = %Chromosome{genes: child1_genes}
      child2 = %Chromosome{genes: child2_genes}
      [child1, child2 | childs]
    end)
  end

  defp get_order_one_child(genes1, genes2) do
    num_genes = Arrays.size(genes1)
    {cut_point1, cut_point2} = misc().get_cut_points(num_genes)
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

  defp preprocess_parents([parent1, parent2 | []], crossover_function) do
    [{parent1, parent2}]
    |> Enum.reduce(
      [],
      crossover_function
    )
  end

  defp preprocess_parents(parents, crossover_function) do
    parents
    |> Enum.chunk_every(2, 1, [hd(parents)])
    |> Enum.map(&List.to_tuple(&1))
    |> Enum.reduce(
      [],
      crossover_function
    )
  end
end
