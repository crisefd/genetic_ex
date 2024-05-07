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
  def selection_function(chromosomes, opts) do
    population_size = Keyword.get(opts, :population_size)
    selection_rate = Keyword.get(opts, :selection_rate)
    Selection.elitism(chromosomes, population_size, selection_rate)
  end

  @impl true
  def mutation_function(population, mutation_rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() <= mutation_rate do
        Mutation.scramble(chromosome)
      else
        chromosome
      end
    end)
  end

  @impl true
  def crossover_function(pairs, population) do
    pairs
    |> Enum.reduce(
      population,
      fn {p1, p2}, new_population ->
        [c1, c2] = Crossover.order_one([p1, p2])
        [c1, c2 | new_population]
      end
    )
  end
end

Genetic.execute(NQueens, selection_rate: 0.8, mutation_rate: 0.05, population_size: 20)
|> IO.inspect()
