defmodule Behaviours.Misc do
  alias Types.Chromosome

  @callback random() :: number()
  @callback random(Enum.t()) :: number()
  @callback take_random(Enum.t(), integer()) :: Enum.t()
  @callback split(map(), integer()) :: tuple()
  @callback sum(map()) :: number()
  @callback weighted_sum(list(number()), list(number())) :: number()
  @callback minmax_fitness(list(Chromosome.t())) :: tuple()
  @callback shuffle(list()) :: list()
  # defp impl, do: Application.get_env(:genetic, :misc, Behaviours.Misc)
end
