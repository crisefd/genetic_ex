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
    |> fill_mating_pool_up([], mating_pool_size)
    |> Enum.take_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp fill_mating_pool_up(population_probabilities, winners, quota) do
    {winners_probs, population_probs} = spin_roulette(population_probabilities)
    {new_winners, _} = winners_probs
    winners = winners ++ new_winners

    if Enum.count(winners) == quota do
      winners
    else
      fill_mating_pool_up(population_probs, winners, quota)
    end
  end

  defp spin_roulette(population_probabilities) do
    spin = :rand.uniform()

    population_probabilities
    |> Enum.reduce({[], []}, fn {chromosome, prob}, {winners_probs, new_population_probs} ->
      if prob >= spin do
        {[{chromosome, prob} | winners_probs], new_population_probs}
      end

      {winners_probs, [{chromosome, prob} | new_population_probs]}
    end)
  end

  defp calculate_probabilities(population, fitness_factor) do
    fitnesses = calculate_normalized_fitnesses(population, fitness_factor)
    sum_fitnesses = fitnesses |> Enum.sum()

    fitnesses
    |> Enum.map(fn fitness ->
      fitness / sum_fitnesses
    end)
  end

  defp calculate_normalized_fitnesses(population, fitness_factor) do
    [min_fitness, max_fitness] =
      Misc.minmax_fitness(population)
      |> Tuple.to_list()
      |> Enum.map(&Kernel.abs/1)

    base = max_fitness + fitness_factor * abs(max_fitness - min_fitness)

    population
    |> Enum.map(fn chromosome ->
      base - chromosome.fitness
    end)
  end

  # def roulette(population, crossover_rate) do
  #   population
  #   |> calculate_probabilities()
  #   |> Enum.chunk_every(2)
  #   |> Enum.reduce([], fn [c1, c2], selections ->
  #     r = :rand.uniform()
  #     upper_bound = c1.selection_probability
  #     lower_bound = c2.selection_probability

  #     if r < crossover_rate && r in lower_bound..upper_bound do
  #       [{c1, c2} | selections]
  #     else
  #       selections
  #     end
  #   end)
  # end

  # defp calculate_probabilities(population, fitness_factor \\ 1.0) do
  #   {min, max} = Misc.minmax_fitness(population)
  #   max = max + 1
  #   base = max + fitness_factor * (max - min)

  #   population =
  #     population
  #     |> Enum.map(fn chromosome ->
  #       normalized_fitness = base - chromosome.fitness
  #       %Chromosome{chromosome | normalized_fitness: normalized_fitness}
  #     end)

  #   fitnesses_sum =
  #     population
  #     |> Enum.reduce(0, fn chromosome, sum ->
  #       chromosome.normalized_fitness + sum
  #     end)

  #   set_probabilities(population, fitnesses_sum)
  # end

  # defp set_probabilities(population, fitnesses_sum) do
  #   [chromosome | chromosomes] =
  #     population
  #     |> Enum.reduce([], fn chromosome, new_population ->
  #       previous_probability =
  #         if Enum.empty?(new_population), do: 0, else: hd(new_population).selection_probability

  #       probability = previous_probability + chromosome.normalized_fitness / fitnesses_sum
  #       new_chromosome = %Chromosome{chromosome | selection_probability: probability}
  #       [new_chromosome | new_population]
  #     end)

  #   [%Chromosome{chromosome | selection_probability: 1.0} | chromosomes]
  # end
end
