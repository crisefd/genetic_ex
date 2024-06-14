defmodule OneMaxProblem do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc
  alias Utilities.Stats

  @impl true
  def genotype() do
    {lower_bounds, upper_bounds} = domain()

    genes =
      0..999
      |> Enum.map(fn i ->
        range = lower_bounds[i]..upper_bounds[i]
        Enum.random(range)
      end)
      |> Arrays.new()

    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(chromosome) do
    Misc.sum(chromosome.genes)
  end

  @impl true
  def terminate?([best | _], _generation, _temperature) do
    best.fitness == Arrays.size(best.genes)
  end

  @impl true
  def domain() do
    lower_bounds = for _ <- 1..1000, do: 0
    upper_bounds = for _ <- 1..1000, do: 1
    {lower_bounds |> Arrays.new(), upper_bounds |> Arrays.new()}
  end
end

results =
  Genetic.execute(
    OneMaxProblem,
    %Utilities.ParameterStore{
      parallelize_fitness_evaluation?: false,
      parallelize_crossover?: false,
      parallelize_mutate?: false
    }
  )

IO.inspect(results, label: "Results")

generations = Keyword.get(results, :generations)

num_evaluations =
  0..generations
  |> Enum.reduce(0, fn generation, sum ->
    {_, %{population_size: num_evals}} = Utilities.Stats.lookup(generation)
    num_evals + sum
  end)

IO.inspect(num_evaluations, label: "Number of evaluations")
