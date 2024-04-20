defmodule CargoProblem do
  alias Types.Chromosome
  @behaviour Behaviours.Problem

  @profits [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  @weights [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
  @weight_limit 40

  @impl true
  def genotype() do
    %Chromosome{
      genes: for(_ <- 0..10, do: Enum.random(0..1)) |> Arrays.new()
    }
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes}) do
    potential_profit =
      Misc.weigh_up_sum(genes, @profits)

    over_limit? =
      Misc.weigh_up_sum(genes, @weights)
      |> Kernel.>(@weight_limit)

    profit = if over_limit?, do: 0, else: potential_profit
    profit
  end

  @impl true
  def terminate?(_, _, temperature) when temperature == 0, do: true

  def terminate?(_population, generation, _temperature) do
    generation == 1000
  end

  @impl true
  def selection_function(population, opts) do
    crossover_rate = Keyword.get(opts, :crossover_rate)
    population_size = Keyword.get(opts, :population_size)
    Selection.roulette(population, population_size, crossover_rate)
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
        {c1, c2} = Crossover.one_point(p1, p2)
        [c1, c2 | new_population]
      end
    )
  end
end

Genetic.execute(CargoProblem, crossover_rate: 0.5, population_size: 1000) |> IO.inspect()
