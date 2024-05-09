defmodule OneMaxProblem do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc

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

Genetic.execute(OneMaxProblem) |> IO.inspect()
