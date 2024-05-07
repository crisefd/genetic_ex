defmodule OneMaxProblem do
  @behaviour Behaviours.Problem
  alias Types.Chromosome

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

  @impl true
  def selection_function(population, opts) do
    population_size = Keyword.get(opts, :population_size)
    selection_rate = Keyword.get(opts, :selection_rate)
    Selection.elitism(population, population_size, selection_rate)
  end

  @impl true
  def mutation_function(population, mutation_rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate do
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
        [c1, c2] = Crossover.one_point([p1, p2])
        [c1, c2 | new_population]
      end
    )
  end
end

Genetic.execute(OneMaxProblem) |> IO.inspect()
