defmodule Genetic do
  @moduledoc """
    Core module of a genetic algorithm. All the generalities of a GA are implemented here:
    - initialize population
    - evaluate population
    - selection of parents for crossover
    - mutation of population
    - Terminate criteria
  The user defines the particularities in their Problem modules and then call Genetic.execute with them
  """

  alias Types.Chromosome

  @type chromosome() :: Chromosome.t()
  @type population() :: list(chromosome())
  @type pair() :: {chromosome(), chromosome()}

  @default_population_size 1000
  @default_mutation_rate 0.05
  @default_selection_rate 0.8
  @default_optimization :max
  @default_logging_step 10
  @default_cooling_rate 0.8
  @default_reinsertion_strategy :none

  @spec execute(problem :: module(), opts :: list()) :: map()

  @doc """
    Main function of a GA.
    It takes a problem module, some hyperparemeters and returns a solution in the form
     %{
        evaluations: The number of fitness evaluations
        generations: The number of generations
        best: The list of genes of the best chromosome,
        best_fitness: The fitness of the best chromosome
      }
  """
  def execute(problem, opts \\ []) do
    initialize_population(&problem.genotype/0, opts)
    |> evolve(problem, 0, 0, 0, opts)
  end

  defp evolve(population, problem, generation, last_optimal_fitness, temperature, opts) do
    cooling_rate = Keyword.get(opts, :cooling_rate, @default_cooling_rate)

    evaluated_population =
      population
      |> evaluate(&problem.fitness_function/1, opts)

    best = hd(evaluated_population)

    new_temperature =
      (1 - cooling_rate) * (temperature + abs(abs(best.fitness) - abs(last_optimal_fitness)))

    log(best, generation, new_temperature, opts)

    if problem.terminate?(
         evaluated_population,
         generation,
         new_temperature
       ) do
      population_size = Keyword.get(opts, :population_size, @default_population_size)
      chromosome_size = best.genes |> Arrays.size()

      %{
        evaluations: population_size * chromosome_size * generation,
        generations: generation,
        best: best.genes,
        best_fitness: best.fitness
      }
    else
      {parent_pairs, pos_selection_population} =
        evaluated_population
        |> select(&problem.selection_function/2, opts)

      parent_pairs
      |> crossover(pos_selection_population, &problem.crossover_function/2, opts)
      |> mutate(&problem.mutation_function/2, opts)
      |> evolve(problem, generation + 1, best.fitness, new_temperature, opts)
    end
  end

  @spec initialize_population(genotype :: function(), opts :: list()) :: population()

  defp initialize_population(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  @spec evaluate(population :: population(), fitness_function :: function(), opts :: list()) ::
          population()

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
    |> Enum.sort_by(& &1.fitness, sorter)
    |> Enum.slice(0, population_size)
  end

  defp select(population, selection_function, opts) do
    reinsertion_strategy = Keyword.get(opts, :reinsertion_strategy, @default_reinsertion_strategy)
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    optimization = Keyword.get(opts, :optimization, @default_optimization)
    selection_rate = Keyword.get(opts, :selection_rate, @default_selection_rate)

    opts = [
      selection_rate: selection_rate,
      optimization: optimization,
      population_size: population_size
    ]

    parents = selection_function.(population, opts)

    apply_reinsertion_strategy(parents, population, reinsertion_strategy)
  end

  defp apply_reinsertion_strategy(parents, population, :children_replace_parents) do
    parent_pairs = pair_parents(parents)

    new_population =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))
      |> MapSet.to_list()

    {parent_pairs, new_population}
  end

  defp apply_reinsertion_strategy(parents, population, :none) do
    parent_pairs = pair_parents(parents)

    {parent_pairs, population}
  end

  defp pair_parents(parents) do
    parents
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(pairs, population, crossover_function, _opts) do
    crossover_function.(pairs, population)
  end

  defp mutate(population, mutation_function, opts) do
    mutation_rate = Keyword.get(opts, :mutation_rate, @default_mutation_rate)
    mutation_function.(population, mutation_rate)
  end

  defp log(best, generation, temperature, opts) do
    logging = Keyword.get(opts, :logging, true)
    step = Keyword.get(opts, :logging_step, @default_logging_step)

    if logging && rem(generation, step) == 0 do
      IO.inspect(generation, label: "Generation")
      IO.inspect(temperature, label: "Temperature")
      IO.inspect(best, label: "Best solution")
      IO.puts("-------------------------")
    end
  end
end
