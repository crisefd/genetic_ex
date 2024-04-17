defmodule Problem do
  alias Types.Chromosome

  @callback genotype :: Chromosome.t()

  @callback fitness_function(Chromosome.t()) :: number()

  @callback terminate?(Enum.t(), integer(), number()) :: boolean()

  @callback selection_function(Enum.t(), Enum.t()) :: Enum.t()

  @callback mutation_function(Enum.t(), number()) :: Enum.t()

end
