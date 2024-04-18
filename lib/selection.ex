defmodule Selection do
  alias Types.Chromosome

  def elitism(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def roulette(population, crossover_rate) do
    population
    |> calculate_probabilities()
    |> Enum.chunk_every(2)
    |> Enum.reduce([], fn [c1, c2], selections ->
      r = :rand.uniform()
      upper_bound = c1.selection_probability
      lower_bound = c2.selection_probability

      if r < crossover_rate && r in lower_bound..upper_bound do
        [{c1, c2} | selections]
      else
        selections
      end
    end)
  end

  defp calculate_probabilities(population, fitness_factor \\ 1.0) do
    {min, max} = Misc.minmax_fitness(population)
    max = max + 1
    base = max + fitness_factor * (max - min)

    population =
      population
      |> Enum.map(fn chromosome ->
        normalized_fitness = base - chromosome.fitness
        %Chromosome{chromosome | normalized_fitness: normalized_fitness}
      end)

    fitnesses_sum =
      population
      |> Enum.reduce(0, fn chromosome, sum ->
        chromosome.normalized_fitness + sum
      end)

    set_probabilities(population, fitnesses_sum)
  end

  defp set_probabilities(population, fitnesses_sum) do
    [chromosome | chromosomes] =
      population
      |> Enum.reduce([], fn chromosome, new_population ->
        previous_probability =
          if Enum.empty?(new_population), do: 0, else: hd(new_population).selection_probability

        probability = previous_probability + chromosome.normalized_fitness / fitnesses_sum
        new_chromosome = %Chromosome{chromosome | selection_probability: probability}
        [new_chromosome | new_population]
      end)

    [%Chromosome{chromosome | selection_probability: 1.0} | chromosomes]
  end
end
