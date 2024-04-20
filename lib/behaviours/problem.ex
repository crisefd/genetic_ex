defmodule Behaviours.Problem do
  alias Types.Chromosome

  @type population() :: list(Chromosome.t())
  @type pair() :: tuple()

  @callback genotype :: Chromosome.t()

  @callback fitness_function(Chromosome.t()) :: number()

  @callback terminate?(population(), integer(), number()) :: boolean()

  @callback selection_function(population(), Enum.t()) :: list(pair())

  @callback crossover_function(list(pair()), population()) :: population()

  @callback mutation_function(population(), number()) :: population()
end
