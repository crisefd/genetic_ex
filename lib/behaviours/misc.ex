defmodule Behaviours.Misc do
  alias Types.Chromosome

  @callback random() :: number()
  @callback random(Enum.t()) :: number()
  @callback split(map(), integer()) :: tuple()
  @callback sum(map()) :: number()
  @callback weigh_up_sum(list(number()), list(number())) :: number()
  @callback minmax_fitness(list(Chromosome.t())) :: tuple()
  # defp impl, do: Application.get_env(:genetic, :misc, Behaviours.Misc)
end
