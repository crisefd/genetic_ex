defmodule Genetic do
  alias Types.Chromosome

  @default_population_size 1000
  @default_mutation_rate 0.05
  @default_optimization :max
  @default_logging_step 10
  @default_cooling_rate 0.8

  def execute(problem, opts \\ []) do
    initialize_population(&problem.genotype/0, opts)
    |> evolve(problem, 0, 0, 0, opts)
  end

  defp initialize_population(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evaluate(population, fitness_function, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    optimization = Keyword.get(opts, :optimization, @default_optimization)
    sorter = if optimization == :max, do: :desc, else: :asc
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(fitness_function, sorter)
    |> Enum.slice(0, population_size)
  end

  defp select(population, selection_function, opts) do
    selection_function.(population, opts)
  end

  defp crossover(pairs, population, crossover_function, _opts) do
   crossover_function.(pairs, population)
  end

  defp mutate(population, mutation_function, opts) do
    mutation_rate = Keyword.get(opts, :mutation_rate, @default_mutation_rate)
    mutation_function.(population, mutation_rate)
  end

  defp evolve(population, problem, generation, last_optimal_fitness, temperature, opts) do
    cooling_rate = Keyword.get(opts, :cooling_rate, @default_cooling_rate)
    sorted_population =
      population
      |> evaluate(&problem.fitness_function/1, opts)

    best = hd(sorted_population)

    new_temperature = (1 - cooling_rate) * (temperature + abs(abs(best.fitness) - abs(last_optimal_fitness)))

    log(best, generation, new_temperature, opts)
    if problem.terminate?(sorted_population, generation, new_temperature) do
      population_size = Keyword.get(opts, :population_size, @default_population_size)
      chromosome_size =  best.genes |> Arrays.size()
      %{
        evaluations: population_size * chromosome_size * generation,
        generations: generation,
        best: best.genes,
        best_fitness: best.fitness
      }
    else
      sorted_population
      |> select(&problem.selection_function/2, opts)
      |> crossover(sorted_population, &problem.crossover_function/2, opts)
      |> mutate(&problem.mutation_function/2, opts)
      |> evolve(problem, generation + 1, best.fitness, new_temperature, opts)
    end
  end

  defp log(best, generation, temperature, opts) do
    logging = Keyword.get(opts, :logging, true)
    step = Keyword.get(opts, :logging_step, @default_logging_step)
    if logging && rem(generation, step) == 0 do
      IO.puts("Generation: #{generation}")
      IO.puts("Best Fit:  #{best.fitness}")
      IO.puts("Temperature: #{temperature}")
    end
  end

end
