defmodule TigerSimulation do
  alias Behaviours.Problem
  alias Types.Chromosome

  @behaviour Problem

  @tropic_scores [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
  @tundra_scores [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]

  @impl true
  def genotype() do
    genes = for(_ <- 1..8, do: Misc.random(0..1)) |> Arrays.new()
    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: traits}) do
    traits
    |> Enum.zip(@tundra_scores)
    |> Enum.reduce(0, fn {trait, score}, sum -> trait * score + sum end)
  end

  @impl true
  def terminate?(_, generation, _) do
    generation === 1_000
  end
end

Genetic.execute(TigerSimulation,
  population_size: 20,
  selection_rate: 0.9,
  mutation_rate: 0.1,
  logging_step: 1
)
|> IO.inspect()
