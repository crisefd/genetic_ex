defmodule Speller do
  @behaviour Behaviours.Problem
  alias Types.Chromosome

  @range ?a..?z
  @target "supercalifragilisticexpialidocious"

  @impl true
  def genotype() do
    size = String.length(@target)
    genes = for(_ <- 1..size, do: Enum.random(@range)) |> Arrays.new()
    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(chromosome) do
    guess = chromosome.genes |> Arrays.to_list() |> List.to_string()
    String.jaro_distance(@target, guess)
  end

  @impl true
  def terminate?([best | _], generation, _) do
    best.fitness == 1 || generation == 50_000
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
  def crossover_function(pairs) do
    pairs
    |> Enum.reduce([], fn {p1, p2}, children ->
      [c1, c2] = Crossover.one_point([p1, p2])
      [c1, c2 | children]
    end)
  end
end

Genetic.execute(Speller,
  mutation_rate: 0.1,
  selection_rate: 0.5,
  logging: true,
  population_size: 1000
)
|> IO.inspect()
