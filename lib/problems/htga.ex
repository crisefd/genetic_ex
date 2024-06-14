defmodule Problems.Htga do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.BenchmarkFunctions

  @impl true
  def genotype() do
    {lower_bounds, upper_bounds} = domain()

    genes =
      0..(dimension() - 1)
      |> Enum.map(fn i ->
        range = lower_bounds[i]..upper_bounds[i]
        Enum.random(range)
      end)
      |> Arrays.new()

    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(solution) do
    {_, _, fun} = BenchmarkFunctions.get(:schwefel)
    fun.(solution.genes)
  end

  @impl true
  def terminate?([best | _chromosomes], generation, _temperature) do
    {_, get_minima, _} = BenchmarkFunctions.get(:schwefel)
    minima = get_minima.(dimension())
    best.fitness === minima || generation == 10_000
  end

  @impl true
  def domain() do
    {{lower_bound, upper_bound}, _, _} = BenchmarkFunctions.get(:schwefel)
    lower_bounds = for _ <- 0..(dimension() - 1), do: lower_bound
    upper_bounds = for _ <- 0..(dimension() - 1), do: upper_bound
    {lower_bounds |> Arrays.new(), upper_bounds |> Arrays.new()}
  end

  def select_taguchi_array() do
    max_num_factors =
      [8, 16, 32, 64, 128, 256, 512, 1024]
      |> Enum.find(nil, fn num_factors ->
        dimension() <= num_factors
      end)

    Utilities.Misc.load_array("L#{max_num_factors}")
  end

  def dimension(), do: 30

  def taguchi_crossover(parents, taguchi_array, optimization_type) do
    [parent1, parent2] = parents
    matrix = fillout_experiment_matrix(parent1, parent2, taguchi_array)
    snrs = calculate_snr(matrix, optimization_type)

    experiment_results = run_experiments(taguchi_array, snrs)

    optimal_genes =
      experiment_results
      |> Enum.with_index()
      |> Enum.reduce(Arrays.new([]), fn {res, idx}, genes ->
        gene = if res == 0, do: parent1[idx], else: parent2[idx]
        Arrays.append(genes, gene)
      end)

    %Chromosome{genes: optimal_genes}
  end

  defp fillout_experiment_matrix(parent1, parent2, taguchi_array) do
    taguchi_array
    |> Arrays.map(fn row ->
      num_cols = Arrays.size(row)

      0..(num_cols - 1)
      |> Enum.map(fn index ->
        if row[index] == 0, do: parent1[index], else: parent2[index]
      end)
      |> Arrays.new()
    end)
  end

  defp calculate_snr(matrix, optimization_type) do
    matrix
    |> Arrays.map(fn row ->
      if optimization_type == :min do
        squares_sum =
          Arrays.map(row, &(&1 ** 2))
          |> Arrays.reduce(0, &Kernel.+/2)

        -10.0 * Math.log10(1.0 / dimension()) + squares_sum
      else
        invert_squares_sum =
          Arrays.map(row, &(1.0 / &1 ** 2))
          |> Arrays.reduce(0, &Kernel.+/2)

        -10.0 * Math.log10(1.0 / dimension()) + invert_squares_sum
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
end
