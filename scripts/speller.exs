defmodule SpellerProblem do
  @behaviour Problem
  alias Types.Chromosome

  @range ?a..?z
  @target "supercalifragilisticexpialidocious"

  @impl true
  def genotype() do
    size = String.length(@target)
    genes = (for _ <- 1..size, do: Enum.random(@range)) |> Arrays.new()

    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(chromosome) do
    guess = chromosome.genes |> Arrays.to_list() |> List.to_string()
    String.jaro_distance(@target, guess)
  end

  @impl true
  def selection_function(population, _opts) do
    Selection.elitism(population)
  end

  @impl true
  def terminate?([best | _population]), do:  best.fitness == 1

  def mutation_function(population, mutation_rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() <= mutation_rate  do
        # option = Enum.random(0..2)
        genes = Mutation.shuffle(chromosome.genes) |> Mutation.one_gene(@range)
        # genes =
        #   case option do
        #     0 -> Mutation.all_genes(chromosome.genes, @range)
        #     1 -> Mutation.shuffle(chromosome.genes)
        #     2 -> Mutation.one_gene(chromosome.genes, @range)
        #   end
        %Chromosome{ genes: genes }
      else
        chromosome
      end
    end)
  end


end

Genetic.execute(SpellerProblem, [mutation_rate: 0.2, logging: true, population_size: 1000]) |> IO.inspect()
