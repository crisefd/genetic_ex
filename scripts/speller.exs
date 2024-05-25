defmodule Speller do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc

  @target "supercalifragilisticexpialidocious"

  @impl true
  def genotype({upper_bounds, lower_bounds}) do
    size = String.length(@target)

    genes =
      for index <- 0..(size - 1) do
        range = lower_bounds[index]..upper_bounds[index]
        Enum.random(range)
      end
      |> Arrays.new()

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

  def get_bounds() do
    size = String.length(@target)
    lower = for(_ <- 1..size, do: ?a) |> Arrays.new()
    upper = for(_ <- 1..size, do: ?z) |> Arrays.new()
    {upper, lower}
  end
end

Genetic.execute(
  Speller,
  %Utilities.ParameterStore{
    mutation_rate: 0.1,
    selection_rate: 0.8,
    logging?: true,
    population_size: 500,
    chromosome_size: 34,
    bounds_function: &Speller.get_bounds/0
  }
)
|> IO.inspect()

# {_, stats} = Utilities.Stats.lookup(500)
# IO.inspect(stats, label: "Stats")
