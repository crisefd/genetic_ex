defmodule HtgaSpeller do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc

  @target "supercalifragilisticexpialidocious"

  @impl true
  def genotype() do
    {upper_bounds, lower_bounds} = domain()

    genes =
      for index <- 0..(dimension() - 1) do
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
    best.fitness == 1 || generation == 1_0000
  end

  def domain() do
    lower = for(_ <- 1..dimension(), do: ?a) |> Arrays.new()
    upper = for(_ <- 1..dimension(), do: ?z) |> Arrays.new()
    {upper, lower}
  end

  def dimension, do: String.length(@target)
end

optimization_type = :max
taguchi_array = Utilities.Misc.select_taguchi_array(HtgaSpeller.dimension())

bounds = HtgaSpeller.domain()

crossover_function = fn parents ->
  childs = Toolbox.Crossover.one_point(parents)
  optimal_childs = Toolbox.Crossover.taguchi_crossover(parents, taguchi_array, optimization_type)
  childs ++ optimal_childs
end

results =
  Genetic.execute(
    HtgaSpeller,
    %Utilities.ParameterStore{
      parallelize_fitness_evaluation?: false,
      parallelize_crossover?: false,
      parallelize_mutate?: false,
      crossover_function: crossover_function,
      mutation_function: &Toolbox.Mutation.scramble/1,
      optimization_type: optimization_type,
      discrete: true,
      logging?: true
    }
  )

IO.inspect(results, label: "Results")
