defmodule CargoProblem do
  alias Types.Chromosome
  @behaviour Problem

  @profits [6, 5, 8, 9, 6, 7, 3, 1, 2, 6]
  @weights [10, 6, 8, 7, 10, 9, 7, 11, 6, 8]
  @weight_limit 40

  @impl true
  def genotype() do
    %Chromosome {
      genes: (for _ <- 0..10, do: Enum.random(0..1)) |> Arrays.new()
    }
  end

  @impl true
  def fitness_function(%Chromosome{ genes: genes }) do
    potential_profit =
      Misc.weigh_up_sum(genes, @profits)

    over_limit? =
      Misc.weigh_up_sum(genes, @weights)
      |> Kernel.>(@weight_limit)

    profit = if over_limit?, do: 0, else: potential_profit
    profit
  end


  @impl true
  def terminate?([best | _]) do
    target = 53
    best.fitness == target
  end

  @impl true
  def selection_function(population, _opts) do
    Selection.elitism(population)
  end

  @impl true
  def mutation_function(population, mutation_rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() <= mutation_rate  do
        %Chromosome{ genes: Mutation.shuffle(chromosome.genes) }
      else
        chromosome
      end
    end)
  end

end

 Genetic.execute(CargoProblem) |> IO.inspect()
