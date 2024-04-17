defmodule OneMaxProblem do
  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = Arrays.new(for _ <- 1..1000, do: Enum.random(0..1))
    %Chromosome{ genes: genes }
  end

  @impl true
  def fitness_function(chromosome) do
    Misc.sum(chromosome.genes)
  end

  @impl true
  def terminate?([best | _population]) do
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
      if :rand.uniform() < mutation_rate  do
        mutated_genes =
          chromosome.genes
          |> Enum.shuffle()
          |> Arrays.new()
        %Chromosome{ chromosome | genes: mutated_genes }
      else
        chromosome
      end
    end)
  end

end

Genetic.execute(OneMaxProblem) |> IO.inspect()
