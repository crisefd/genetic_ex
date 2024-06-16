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
  alias Utilities.Stats
  alias Utilities.Misc
  alias Utilities.Genealogy
  alias Utilities.ParameterStore, as: Options

  @type chromosome() :: Chromosome.t()
  @type pair() :: {chromosome(), chromosome()}
  @type options() :: Options.t()
  @type arrays() :: Arrays.t()

  @spec execute(problem :: module(), opts :: options()) :: keyword()

  @doc """
    Main function of a GA.
    It takes a problem module, some hyperparemeters and returns a solution in the form
     [
        generations: The number of generations
        best_genes: The best chromosome,
        best_fitness: The fitness of the best chromosome
    ]
  """
  def execute(problem, opts \\ %Options{})

  def execute(problem, opts) do
    initialize_population(&problem.genotype/0, opts)
    |> evolve(problem, 0, 0, 0.0, opts)
  end

  @spec initialize_population(genotype :: function(), opts :: options()) :: list(chromosome())

  def initialize_population(genotype, opts) do
    population_size = opts.population_size
    population = for _ <- 1..population_size, do: genotype.()

    add_to_genealogy(population)

    population
  end

  @spec select(population :: list(chromosome()), opts :: options()) ::
          {list(pair()), list(chromosome()), list(chromosome())}

  def select(population, opts) do
    population_size = opts.population_size
    selection_rate = opts.selection_rate
    selection_function = opts.selection_function
    parents = selection_function.(population, population_size, selection_rate)

    parent_pairs = pair_parents_up(parents)

    leftover =
      population
      |> MapSet.new()
      |> MapSet.difference(MapSet.new(parents))
      |> MapSet.to_list()

    {parent_pairs, parents, leftover}
  end

  @spec evaluate(
          population :: list(chromosome()),
          fitness_function :: function(),
          opts :: options()
        ) ::
          list(chromosome())

  def evaluate(population, fitness_function, opts) do
    optimization_type = opts.optimization_type
    parallelize_fitness_evaluation? = opts.parallelize_fitness_evaluation?
    sorter = if optimization_type == :max, do: :desc, else: :asc

    if parallelize_fitness_evaluation? do
      parallel_evaluate(population, fitness_function, sorter)
    else
      sequential_evaluate(population, fitness_function, sorter)
    end
  end

  @spec crossover(pairs :: list(pair()), opts :: options()) ::
          list(chromosome())

  def crossover(pairs, opts) do
    crossover_function = opts.crossover_function
    parallelize_crossover? = opts.parallelize_crossover?

    if parallelize_crossover? do
      parallel_crossover(pairs, crossover_function)
    else
      sequential_crossover(pairs, crossover_function)
    end
  end

  @spec mutate(population :: list(chromosome()), opts :: options()) ::
          list(chromosome())

  def mutate(population, opts) do
    mutation_rate = opts.mutation_rate
    mutation_function = opts.mutation_function
    parallelize_mutate? = opts.parallelize_mutate?

    if parallelize_mutate? do
      parallel_mutate(population, mutation_rate, mutation_function)
    else
      sequential_mutate(population, mutation_rate, mutation_function)
    end
  end

  @spec reinsert(
          parents :: list(chromosome()),
          offspring :: list(chromosome()),
          leftover :: list(chromosome()),
          opts :: options()
        ) :: list(chromosome())

  def reinsert(parents, offspring, leftover, opts) do
    survival_rate = opts.survival_rate
    optimization = opts.optimization_type
    population_size = opts.population_size
    reinsert_function = opts.reinsert_function

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

  @spec evolve(
          population :: list(chromosome()),
          problem :: module(),
          generation :: integer(),
          last_optimal_fitness :: number(),
          temperature :: float(),
          opts :: options()
        ) :: keyword()

  @doc """
    Performs Evaluation -> Selection -> Crossover -> Mutation -> Reinsertion
    in a loop and returns the result when Termination criteria has been met
  """
  def evolve(population, problem, generation, last_optimal_fitness, temperature, opts) do
    cooling_rate = opts.cooling_rate
    population_size = opts.population_size

    evaluated_population =
      population
      |> evaluate(&problem.fitness_function/1, opts)
      |> record_stats(generation, opts)
      |> resize_population(population_size)

    best = hd(evaluated_population)

    new_temperature =
      (1 - cooling_rate) * (temperature + abs(abs(best.fitness) - abs(last_optimal_fitness)))

    log(best, generation, new_temperature, opts)

    if problem.terminate?(
         evaluated_population,
         generation,
         new_temperature
       ) do
      [
        generations: generation,
        best_genes: best.genes,
        best_fitness: best.fitness
      ]
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

  defp record_stats(population, generation, opts) do
    stats_functions = opts.stats_functions

    data = [
      population: population,
      generation: generation,
      stats_functions: stats_functions
    ]

    Stats.record(data)

    population
  end

  defp pair_parents_up(parents) do
    parents
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp resize_population(population, population_size) do
    population
    |> Enum.slice(0, population_size)
  end

  defp add_to_genealogy(chromosomes) do
    Genealogy.add_chromosomes(chromosomes)
  end

  defp add_to_genealogy(parent, child) do
    Genealogy.add_chromosomes(parent, child)
  end

  defp add_to_genealogy(parent1, parent2, child) do
    Genealogy.add_chromosomes(parent1, parent2, child)
  end

  defp add_multiple_to_genealogy(_, _, []), do: :ok

  defp add_multiple_to_genealogy(parent1, parent2, [child | children]) do
    add_to_genealogy(parent1, parent2, child)
    add_multiple_to_genealogy(parent1, parent2, children)
  end

  defp parallel_crossover(pairs, crossover_function) do
    pairs
    |> Misc.pmap(fn {parent1, parent2} ->
      params = [parent1, parent2]

      fn ->
        new_children = apply(crossover_function, params)
        add_multiple_to_genealogy(parent1, parent2, new_children)
        new_children
      end
    end)
    |> List.flatten()
  end

  defp sequential_crossover(pairs, crossover_function) do
    pairs
    |> Enum.reduce([], fn {parent1, parent2}, children ->
      params = [[parent1, parent2]]
      new_children = apply(crossover_function, params)
      add_multiple_to_genealogy(parent1, parent2, new_children)
      new_children ++ children
    end)
  end

  defp parallel_mutate(population, mutation_rate, mutation_function) do
    population
    |> Enum.filter(fn _ -> Misc.random() <= mutation_rate end)
    |> Misc.pmap(fn chromosome ->
      fn ->
        params = [chromosome]
        mutant = apply(mutation_function, params)
        add_to_genealogy(chromosome, mutant)
        mutant
      end
    end)
  end

  defp sequential_mutate(population, mutation_rate, mutation_function) do
    population
    |> Enum.reduce([], fn chromosome, mutants ->
      if Misc.random() <= mutation_rate do
        params = [chromosome]
        mutant = apply(mutation_function, params)
        add_to_genealogy(chromosome, mutant)
        [mutant | mutants]
      else
        mutants
      end
    end)
  end

  defp sequential_evaluate(population, fitness_function, sorter) do
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(& &1.fitness, sorter)
  end

  defp parallel_evaluate(population, fitness_function, sorter) do
    population
    |> Misc.pmap(fn chromosome ->
      fn ->
        fitness = fitness_function.(chromosome)
        age = chromosome.age + 1
        %Chromosome{chromosome | fitness: fitness, age: age}
      end
    end)
    |> Enum.sort_by(& &1.fitness, sorter)
  end

  defp log(best, generation, temperature, opts) do
    logging = opts.logging?
    step = opts.logging_step

    if logging && rem(generation, step) == 0 do
      IO.inspect(generation, label: "Generation")
      IO.inspect(temperature, label: "Temperature")
      IO.inspect(best, label: "Best solution")
      IO.puts("-------------------------")
    end
  end
end
