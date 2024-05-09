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
  @default_survival_rate 0.1

  @spec execute(problem :: module(), opts :: list()) :: map()

  @doc """
    Main function of a GA.
    It takes a problem module, some hyperparemeters and returns a solution in the form
     %{
        evaluations: The number of fitness evaluations
        generations: The number of generations
        best: The best chromosome,
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

      %{
        evaluations: population_size * generation,
        generations: generation,
        best: best.genes,
        best_fitness: best.fitness
      }
    else
      {parent_pairs, parents, leftover} =
        evaluated_population
        |> select(opts)

      children =
        parent_pairs
        |> crossover(opts)

      mutants =
        evaluated_population
        |> mutate(opts)

      reinsert(parents, children ++ mutants, leftover, opts)
      |> evolve(problem, generation + 1, best.fitness, new_temperature, opts)
    end
  end

  defp reinsert(parents, offspring, leftover, opts) do
    survival_rate = Keyword.get(opts, :survival_rate, @default_survival_rate)
    optimization = Keyword.get(opts, :optimization, @default_optimization)
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    reinsert_function = Keyword.get(opts, :reinsert_function, &Reinsertion.elitist/6)

    new_population =
      apply(reinsert_function, [
        parents,
        offspring,
        leftover,
        population_size,
        optimization,
        survival_rate
      ])

    new_population_size = Enum.count(new_population)

    if new_population_size < population_size do
      raise "Your reinsertation strategy produced less individuals
            (#{new_population_size}) than the minimum required (#{population_size}).
            The number of inviduals needs to be larger than or equal to #{population_size}"
    end

    new_population
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

  defp select(population, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    # optimization = Keyword.get(opts, :optimization, @default_optimization)
    selection_rate = Keyword.get(opts, :selection_rate, @default_selection_rate)
    selection_function = Keyword.get(opts, :selection_function, &Selection.elitist/3)
    parents = selection_function.(population, population_size, selection_rate)

    parent_pairs = pair_parents_up(parents)

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))
      |> MapSet.to_list()

    {parent_pairs, parents, leftover}
  end

  defp pair_parents_up(parents) do
    parents
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(pairs, opts) do
    crossover_function = Keyword.get(opts, :crossover_function, &Crossover.one_point/1)

    pairs
    |> Enum.reduce([], fn {p1, p2}, children ->
      [c1, c2] = crossover_function.([p1, p2])
      [c1, c2 | children]
    end)
  end

  defp mutate(population, opts) do
    mutation_rate = Keyword.get(opts, :mutation_rate, @default_mutation_rate)
    mutation_function = Keyword.get(opts, :mutation_function, &Mutation.scramble/1)

    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate do
        mutation_function.(chromosome)
      else
        chromosome
      end
    end)
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
