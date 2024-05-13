defmodule Dummy do
  alias Types.Chromosome
  alias Utilities.Misc
  @behaviour Behaviours.Problem

  @impl true
  def genotype(_) do
    genes = for(_ <- 1..100, do: Misc.random(0..1)) |> Arrays.new()
    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes}) do
    Enum.sum(genes)
  end

  @impl true
  def terminate?(_, generation, _) do
    generation == 1
  end
end

opts = [population_size: 100, survival_rate: 0.3]

population = Genetic.initialize_population(&Dummy.genotype/0, opts)

{selected_pairs, _, _} = Genetic.select(population, selection_rate: 1.0)

Benchee.run(%{
  "initialize_population" => fn ->
    Genetic.initialize_population(&Dummy.genotype/0, opts)
  end,
  "evaluate" => fn -> Genetic.evaluate(population, &Dummy.fitness_function/1, opts) end,
  "select" => fn -> Genetic.select(population, opts) end,
  "crossover" => fn -> Genetic.crossover(selected_pairs, opts) end,
  "mutate" => fn -> Genetic.mutate(population, opts) end,
  "evolve" => fn -> Genetic.evolve(population, Dummy, 0, 0, 0, opts) end
})
