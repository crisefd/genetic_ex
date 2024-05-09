defmodule NQueens do
  alias Behaviours.Problem
  alias Types.Chromosome
  @behaviour Problem

  @range 0..7

  @impl true
  def genotype() do
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

  @impl true
  def crossover_function(pairs) do
    pairs
    |> Enum.reduce([], fn {p1, p2}, children ->
      [c1, c2] = Crossover.one_point([p1, p2])
      [c1, c2 | children]
    end)
  end
end

Genetic.execute(NQueens, selection_rate: 0.8, mutation_rate: 0.05, population_size: 20)
|> IO.inspect()
