defmodule SpellerProblem do
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
  def selection_function(population, opts) do
    crossover_rate = Keyword.get(opts, :crossover_rate)
    population_size = Keyword.get(opts, :population_size)
    Selection.roulette(population, population_size, crossover_rate)
  end

  @impl true
  def terminate?([best | _], generation, _), do: best.fitness == 1 || generation == 50_000

  @impl true
  def mutation_function(population, mutation_rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() <= mutation_rate do
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

Genetic.execute(SpellerProblem,
  mutation_rate: 0.1,
  crossover_rate: 0.5,
  logging: true,
  population_size: 1000
)
|> IO.inspect()
