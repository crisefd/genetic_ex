defmodule Speller do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc

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
    best.fitness == 1 || generation == 1_000
  end
end

Genetic.execute(Speller,
  mutation_rate: 0.1,
  selection_rate: 0.5,
  logging: true,
  population_size: 1000
)
|> IO.inspect()

{_, stats} = Utilities.Stats.lookup(500)
IO.inspect(stats, label: "Stats")
