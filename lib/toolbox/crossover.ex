defmodule Toolbox.Crossover do
  @moduledoc """
    The Crossover module contains some of the most commonly used crossover strategies for genetic algorithms
  """

  require Integer
  alias Types.Chromosome

  @type chromosome() :: Chromosome.t()
  @type array() :: Arrays.t()
  @type optimization_type() :: :min | :max

  @spec misc() :: module()
  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  @spec one_point(
          parents :: list(chromosome()),
          cut_point :: integer()
        ) ::
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
      if num_genes == 0 do
        [parent1, parent2 | childs]
      else
        {{l1, r1}, {l2, r2}} =
          {misc().split(parent1.genes, cut_point), misc().split(parent2.genes, cut_point)}

        child1 = %Chromosome{genes: Arrays.concat(l1, r2)}
        child2 = %Chromosome{genes: Arrays.concat(l2, r1)}

        [child1, child2 | childs]
      end
    end)
  end

  @spec convex_one_point(parents :: list(chromosome()), bounds :: {array(), array()}) ::
          list(chromosome())

  def convex_one_point([], _), do: raise("The list of parents cannot be empty")

  def convex_one_point(parents, {lower_bounds, upper_bounds}) do
    num_genes = Arrays.size(hd(parents).genes)
    cut_point = misc().random(0..(num_genes - 1))

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      if num_genes == 0 do
        [parent1, parent2 | childs]
      else
        beta = misc().random(0..10) / 10

        x1 = parent1.genes[cut_point]
        y1 = parent2.genes[cut_point]
        l = lower_bounds[cut_point]
        u = upper_bounds[cut_point]

        x2 = x1 + beta * (y1 - x1)
        y2 = l + beta * (u - l)

        genes1 = Arrays.replace(parent1.genes, cut_point, x2)
        genes2 = Arrays.replace(parent2.genes, cut_point, y2)

        {{l1, r1}, {l2, r2}} =
          {misc().split(genes1, cut_point), misc().split(genes2, cut_point)}

        child1 = %Chromosome{genes: Arrays.concat(l1, r2)}
        child2 = %Chromosome{genes: Arrays.concat(l2, r1)}

        [child1, child2 | childs]
      end
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

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      if num_genes in 0..4 do
        [parent1, parent2 | childs]
      else
        {cut_point1, cut_point2} = misc().get_cut_points(num_genes)
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
      end
    end)
  end

  @spec scattered(parents :: list(chromosome()), rate :: float()) ::
          list(chromosome())

  @doc """
    Takes two chromosomes, applies Scattered (uniform) crossover and returns a list containing the resulting offspring
  """
  def scattered(parents, rate \\ 0.5)

  def scattered([], _), do: raise("The list of parents cannot be empty")

  def scattered([_parent | []] = parents, _), do: parents

  def scattered(parents, rate) do
    num_genes = Arrays.size(hd(parents).genes)

    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      if num_genes in 0..2 do
        [parent1, parent2 | childs]
      else
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
      end
    end)
  end

  @spec arithmetic(
          parents :: list(chromosome()),
          percentage :: float()
        ) ::
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
      if num_genes == 0 do
        [parent1, parent2 | childs]
      else
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
      end
    end)
  end

  @spec order_one(parents :: list(chromosome())) ::
          list(chromosome())

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

      num_genes = Arrays.size(genes1)
      child1_genes = get_order_one_child(genes1, genes2, num_genes)
      child2_genes = get_order_one_child(genes2, genes1, num_genes)

      child1 = %Chromosome{genes: child1_genes}
      child2 = %Chromosome{genes: child2_genes}
      [child1, child2 | childs]
    end)
  end

  @spec taguchi_crossover(list(chromosome()), array(), optimization_type()) :: list(chromosome())

  def taguchi_crossover([], _, _), do: raise("The list of parents cannot be empty")

  def taguchi_crossover([_parent | []] = parents, _, _), do: parents

  def taguchi_crossover(parents, taguchi_array, optimization_type) do
    parents
    |> preprocess_parents(fn {parent1, parent2}, childs ->
      genes1 = parent1.genes
      genes2 = parent2.genes
      dimension = Arrays.size(genes1)

      matrix = fillout_experiment_matrix(genes1, genes2, taguchi_array)
      snrs = calculate_snr(matrix, dimension, optimization_type)
      experiment_results = run_experiments(taguchi_array, snrs)

      optimal_genes =
        experiment_results
        |> Enum.with_index()
        |> Enum.reduce(Arrays.new([]), fn {res, idx}, genes ->
          gene = if res == 0, do: genes1[idx], else: genes2[idx]
          if is_nil(gene), do: genes, else: Arrays.append(genes, gene)
        end)

      child = %Chromosome{genes: optimal_genes}

      [child | childs]
    end)
  end

  defp fillout_experiment_matrix(genes1, genes2, taguchi_array) do
    taguchi_array
    |> Arrays.map(fn row ->
      num_cols = Arrays.size(row)

      0..(num_cols - 1)
      |> Enum.map(fn index ->
        if row[index] == 0, do: genes1[index], else: genes2[index]
      end)
      |> Arrays.new()
    end)
  end

  defp calculate_snr(matrix, dimension, optimization_type) do
    matrix
    |> Arrays.map(fn row ->
      if optimization_type == :min do
        squares_sum =
          Arrays.map(row, fn val ->
            if is_nil(val), do: 0, else: val ** 2
          end)
          |> Arrays.reduce(0, &Kernel.+/2)

        -10.0 * Math.log10(1.0 / dimension) + squares_sum
      else
        invert_squares_sum =
          Arrays.map(row, &(1.0 / &1 ** 2))
          |> Arrays.reduce(0, &Kernel.+/2)

        -10.0 * Math.log10(1.0 / dimension) + invert_squares_sum
      end
    end)
  end

  defp run_experiments(taguchi_array, snrs) do
    num_experiments = Arrays.size(taguchi_array)
    num_factors = Arrays.size(taguchi_array[0])

    factors_experiment_results =
      0..(num_factors - 1)
      |> Enum.map(fn factor_idx ->
        col =
          taguchi_array
          |> fetch_col(factor_idx, num_experiments, num_factors)

        effects_duple =
          0..(num_experiments - 1)
          |> Enum.reduce({0, 0}, fn exp_idx, {lvl1_effects_sum, lvl2_effects_sum} ->
            snr_effect = snrs[exp_idx]

            if col[exp_idx] == 1 do
              {lvl1_effects_sum + snr_effect, lvl2_effects_sum}
            else
              {lvl1_effects_sum, lvl2_effects_sum + snr_effect}
            end
          end)

        {lvl1_total, lvl2_total} = effects_duple

        experiment_result = if lvl1_total > lvl2_total, do: 0, else: 1

        experiment_result
      end)

    factors_experiment_results
  end

  defp fetch_col(taguchi_array, target_col_idx, num_experiments, num_factors) do
    coors =
      for col_index <- List.duplicate(target_col_idx, num_factors),
          row_index <- 0..(num_experiments - 1) do
        {row_index, col_index}
      end

    coors
    |> Enum.map(fn {i, j} -> taguchi_array[i][j] end)
    |> Arrays.new()
  end

  defp get_order_one_child(_, _, 0), do: raise("The list of genes cannot be empty")

  defp get_order_one_child(genes1, _, num_genes) when num_genes <= 4, do: genes1

  defp get_order_one_child(genes1, genes2, num_genes) do
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

    initial_child_genes =
      front
      |> Arrays.concat(middle)
      |> Arrays.concat(back)

    {_, child_genes} =
      0..(num_genes - 1)
      |> Enum.reduce({left_over, Arrays.new()}, fn i, {lo, result} ->
        cond do
          Enum.empty?(lo) or !is_nil(initial_child_genes[i]) ->
            {lo, Arrays.append(result, genes1[i])}

          true ->
            {tl(lo), Arrays.append(result, hd(lo))}
        end
      end)

    # if Arrays.size(child_genes) != num_genes do
    #   raise "The child chromosome has a different number of genes than its parent. Expected #{num_genes} but got #{Arrays.size(child_genes)}"
    # end

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
