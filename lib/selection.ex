defmodule Selection do
  require Integer

  def misc, do: Application.get_env(:genetic, :misc)

  def elitism(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def roulette(population, population_size, selection_rate, fitness_factor \\ 1.0) do
    probabilities = calculate_probabilities(population, fitness_factor)
    mating_pool_size = floor(population_size * selection_rate)

    mating_pool_size =
      if Integer.is_odd(mating_pool_size), do: mating_pool_size + 1, else: mating_pool_size

    population
    |> Enum.zip(probabilities)
    |> go_to_casino([], 0, mating_pool_size)
    |> misc().shuffle()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def tournament(population, population_size, selection_rate, optimization) do
    compare_function = if optimization == :max, do: &Kernel.max/2, else: &Kernel.min/2

    mating_pool_size = floor(population_size * selection_rate)

    mating_pool_size =
      if Integer.is_odd(mating_pool_size), do: mating_pool_size + 1, else: mating_pool_size

    population
    |> Arrays.new()
    |> hold_matches(population_size, compare_function, [], 0, mating_pool_size)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp hold_matches(_, _, _, pool, num_matches, quota) when num_matches == quota do
    pool
  end

  defp hold_matches(population, population_size, compare_function, pool, num_matches, quota) do
    index1 = misc().random(0..(population_size - 1))
    index2 = misc().random(0..(population_size - 1))

    participant1 = Arrays.get(population, index1)
    participant2 = Arrays.get(population, index2)

    best_fitness = compare_function.(participant1.fitness, participant2.fitness)

    winner = if best_fitness == participant1.fitness, do: participant1, else: participant2

    hold_matches(
      population,
      population_size,
      compare_function,
      [winner | pool],
      num_matches + 1,
      quota
    )
  end

  defp go_to_casino(_, pool, num_spins, quota) when num_spins == quota, do: pool

  defp go_to_casino(population_probabilities, pool, num_spins, quota) do
    {chromosome, _} = spin_roulette(population_probabilities)
    go_to_casino(population_probabilities, [chromosome | pool], num_spins + 1, quota)
  end

  defp spin_roulette(population_probabilities) do
    spin = misc().random()

    population_probabilities
    |> Enum.find(fn {_, probability} ->
      spin < probability
    end)
  end

  defp calculate_probabilities(population, fitness_factor) do
    fitnesses = calculate_normalized_fitnesses(population, fitness_factor)
    fitnesses_fum = fitnesses |> Enum.sum()

    {_, [_ | probabilities]} =
      fitnesses
      |> Enum.reduce({0, []}, fn fitness, {prev_prob, probs} ->
        new_prob = prev_prob + fitness / fitnesses_fum
        {new_prob, [new_prob | probs]}
      end)

    [1.0 | probabilities]
    |> Enum.reverse()
  end

  defp calculate_normalized_fitnesses(population, fitness_factor) do
    # [min_fitness, max_fitness] =
    #   misc().minmax_fitness(population)
    #   |> Tuple.to_list()
    #   |> Enum.map(&Kernel.abs/1)

    {min_fitness, max_fitness} = misc().minmax_fitness(population)
    max_fitness = max_fitness + 1
    base = max_fitness + fitness_factor * (max_fitness - min_fitness)

    population
    |> Enum.map(fn chromosome ->
      base - chromosome.fitness
    end)
  end
end
