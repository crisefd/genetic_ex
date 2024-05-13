defmodule Cargo do
  alias Types.Chromosome
  alias Utilities.Misc
  @behaviour Behaviours.Problem

  @profits [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  @weights [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
  @weight_limit 40

  @impl true
  def genotype(_) do
    %Chromosome{
      genes: for(_ <- 0..10, do: Enum.random(0..1)) |> Arrays.new()
    }
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes}) do
    potential_profit =
      Misc.weighted_sum(genes, @profits)

    over_limit? =
      Misc.weighted_sum(genes, @weights)
      |> Kernel.>(@weight_limit)

    profit = if over_limit?, do: 0, else: potential_profit
    profit
  end

  @impl true
  def terminate?(_population, generation, temperature) do
    generation == 1000 || temperature == 0
  end
end

Genetic.execute(Cargo, selection_rate: 0.8, mutation_rate: 0.1) |> IO.inspect()
