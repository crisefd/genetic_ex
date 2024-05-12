defmodule Behaviours.Misc do
  alias Types.Chromosome

  @type chromosome :: Chromosome.t()
  @type collection :: Enum.t()

  @callback random() :: number()
  @callback random(number(), number()) :: number()
  @callback random(collection()) :: number()
  @callback take_random(collection(), integer()) :: collection()
  @callback split(map(), integer()) :: tuple()
  @callback pmap(collection(), function()) :: list()
  # @callback preduce(collection(), any(), function()) :: any()
  @callback sum(map()) :: number()
  @callback weighted_sum(list(number()), list(number())) :: number()
  @callback minmax_fitness(list(chromosome())) :: tuple()
  @callback shuffle(list()) :: list()
  @callback get_cut_points(integer()) :: {integer(), integer()}
  @callback min_fitness(list(chromosome())) :: number()
  @callback max_fitness(list(chromosome())) :: number()
  @callback mean_fitness(list(chromosome())) :: number()
  @callback count_chromosomes(list(chromosome())) :: integer()
  # defp impl, do: Application.get_env(:genetic, :misc, Behaviours.Misc)
end
