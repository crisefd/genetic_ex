defmodule Htga do
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
end

optimization_type = :min

taguchi_array = Htga.select_taguchi_array()

bounds = Htga.domain()

crossover_function = fn parents, _ ->
  childs = Toolbox.Crossover.convex_one_point(parents, bounds)
  optimal_childs = Toolbox.Crossover.taguchi_crossover(parents, taguchi_array, optimization_type)
  childs ++ optimal_childs
end

mutation_function = fn chromosome, _ ->
  Toolbox.Mutation.convex(chromosome)
end

results =
  Genetic.execute(
    Htga,
    %Utilities.ParameterStore{
      parallelize_fitness_evaluation?: false,
      parallelize_crossover?: false,
      parallelize_mutate?: false,
      crossover_function: crossover_function,
      mutation_function: mutation_function,
      optimization_type: optimization_type,
      discrete: false,
      logging?: true
    }
  )

IO.inspect(results, label: "Results")
