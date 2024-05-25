defmodule NQueens do
  alias Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc
  @behaviour Problem

  @range 0..7

  @impl true
  def genotype(_) do
    %Chromosome{
      genes: Misc.shuffle(@range) |> Arrays.new()
    }
  end

  @impl true
  def fitness_function(solution) do
    diagonal_clashes =
      for i <- @range, j <- @range do
        if i != j do
          dx = abs(i - j)
          dy = abs(solution.genes[i] - solution.genes[j])
          if dx == dy, do: 1, else: 0
        else
          0
        end
      end

    length(Enum.uniq(solution.genes)) - Enum.sum(diagonal_clashes)
  end

  @impl true
  def terminate?([best | _], generation, _temperature) do
    best.fitness == 8 || generation == 1000
  end
end

Genetic.execute(NQueens)
|> IO.inspect()
