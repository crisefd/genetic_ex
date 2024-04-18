defmodule OneMaxProblem do
  @behaviour Problem
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

  def terminate?(_population, generation, temperature) when temperature == 0, do: true

  def terminate?([best | _population], _generation, _temperature) do
    best.fitness == Arrays.size(best.genes)
  end

  @impl true
  def selection_function(population, _opts) do
    Selection.elitism(population)
  end

  @impl true
  def mutation_function(population, mutation_rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate do
        Mutation.shuffle(chromosome)
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
        {c1, c2} = Crossover.one_point(p1, p2)
        [c1, c2 | new_population]
      end
    )
  end
end

Genetic.execute(OneMaxProblem) |> IO.inspect()
