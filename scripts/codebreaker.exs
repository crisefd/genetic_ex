defmodule Codebreaker do
  alias Behaviours.Problem
  alias Types.Chromosome
  import Bitwise

  @behaviour Problem

  @bit_range 1..64

  @impl true
  def genotype() do
    %Chromosome{
      genes: for(_ <- @bit_range, do: Enum.random(0..1)) |> Arrays.new()
    }
  end

  @impl true
  def selection_function(population, opts) do
    selection_rate = Keyword.get(opts, :selection_rate)
    population_size = Keyword.get(opts, :population_size)
    Selection.elitism(population, population_size, selection_rate)
  end

  @impl true
  def fitness_function(solution) do
    target = "ILoveGeneticAlgorithms"
    encrypted = ~c"LIjs`B`k`qlfDibjwlqmhv"

    cipher =
      fn word, key ->
        word
        |> Enum.map(fn char ->
          bxor(char, key) |> rem(32768)
        end)
      end

    key =
      solution.genes
      |> Arrays.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(target, guess)
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
        [c1, c2] = Crossover.one_point([p1, p2])
        [c1, c2 | new_population]
      end
    )
  end
end

Genetic.execute(Codebreaker,
  mutation_rate: 0.05,
  selection_rate: 0.8,
  logging: true,
  population_size: 1000
)
|> IO.inspect()
