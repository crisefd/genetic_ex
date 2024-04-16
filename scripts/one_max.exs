defmodule OneMaxProblem do
  @behaviour Problem
  alias Types.Chromosome
  require Arrays
  require Utilities

  @impl true
  def genotype() do
    genes = Arrays.new(for _ <- 1..1000, do: Enum.random(0..1))
    %Chromosome{ genes: genes }
  end

  @impl true
  def fitness_function(chromosome) do
    Utilities.sum(chromosome.genes)
  end

  @impl true
  def terminate?([best | _population]) do
    best.fitness === Arrays.size(best.genes)
  end

end

Genetic.execute(OneMaxProblem) |> IO.inspect()
