defmodule OneMaxProblem do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc
  alias Utilities.Stats

  @impl true
  def genotype() do
    genes = Arrays.new(for _ <- 1..1000, do: Enum.random(0..1))
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
end

results = Genetic.execute(OneMaxProblem)
IO.inspect(results)

generations = Keyword.get(results, :generations)

num_evaluations =
  0..generations
  |> Enum.reduce(0, fn generation, sum ->
    {_, %{population_size: num_evals}} = Utilities.Stats.lookup(generation)
    num_evals + sum
  end)

IO.inspect(num_evaluations, label: "Number of evaluations")
