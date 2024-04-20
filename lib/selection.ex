defmodule Selection do
  require Integer
  alias Types.Chromosome

  def elitism(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def roulette(population, population_size, crossover_rate, fitness_factor \\ 1.0) do
    probabilities = calculate_probabilities(population, fitness_factor)
    mating_pool_size = floor(population_size * crossover_rate)

    mating_pool_size =
      if Integer.is_odd(mating_pool_size), do: mating_pool_size + 1, else: mating_pool_size

    population
    |> Enum.zip(probabilities)
    |> fill_mating_pool_up([], 0, mating_pool_size)
    |> Misc.shuffle()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def fill_mating_pool_up(_, pool, num_spins, quota) when num_spins == quota, do: pool

  def fill_mating_pool_up(population_probabilities, pool, num_spins, quota) do
    {chromosome, _} = spin_roulette(population_probabilities)
    fill_mating_pool_up(population_probabilities, [chromosome | pool], num_spins + 1, quota)
  end

  def spin_roulette(population_probabilities) do
    spin = Misc.random()

    population_probabilities
    |> Enum.find(fn {_, probability} ->
      spin < probability
    end)
  end

  def calculate_probabilities(population, fitness_factor) do
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

  def calculate_normalized_fitnesses(population, fitness_factor) do
    # [min_fitness, max_fitness] =
    #   Misc.minmax_fitness(population)
    #   |> Tuple.to_list()
    #   |> Enum.map(&Kernel.abs/1)

    {min_fitness, max_fitness} = Misc.minmax_fitness(population)
    max_fitness = max_fitness + 1
    base = max_fitness + fitness_factor * (max_fitness - min_fitness)

    population
    |> Enum.map(fn chromosome ->
      base - chromosome.fitness
    end)
  end
end
