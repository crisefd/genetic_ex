defmodule Schedule do
  alias Behaviours.Problem
  alias Types.Chromosome

  @behaviour Problem
  @penalty -99999
  @weight 1 / 3
  @max_credits 18
  @credit_hours [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  @difficulties [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  @usefulnesses [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  @interests [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]

  @impl true
  def genotype() do
    genes =
      for(_ <- 1..10, do: Misc.random(0..1))
      |> Arrays.new()

    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes} = _solution) do
    schedule = Arrays.to_list(genes)

    total_fitness =
      [schedule, @difficulties, @usefulnesses, @interests]
      |> Enum.zip()
      |> Enum.map(fn {class, difficulty, usefulness, interest} ->
        class * @weight * (usefulness + interest - difficulty)
      end)
      |> Enum.sum()

    credits =
      schedule
      |> Enum.zip(@credit_hours)
      |> Enum.map(fn {class, credits} -> class * credits end)
      |> Enum.sum()

    if credits > @max_credits, do: @penalty, else: total_fitness
  end

  @impl true
  def selection_function(population, population_size, selection_rate, _optimization_type) do
    Selection.elitist(population, population_size, selection_rate)
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

  @impl true
  def reinsert_function(parents, offspring, leftover, _, _, _) do
    Reinsertion.pure(parents, offspring, leftover)
  end

  @impl true
  def terminate?(_, 1000, _), do: true
  def terminate?(_, _, _), do: false
end

Genetic.execute(Schedule, selection_rate: 0.8, mutation_rate: 0.1) |> IO.inspect()
