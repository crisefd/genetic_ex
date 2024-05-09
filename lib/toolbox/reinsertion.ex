defmodule Toolbox.Reinsertion do
  # alias Types.Chromosome

  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  def pure(_parents, offspring, _leftover), do: offspring

  def elitist(parents, offspring, leftover, population_size, optimization_type, survival_rate) do
    sorter = if optimization_type == :max, do: :desc, else: :asc
    old = parents ++ leftover
    num_survivors = floor(population_size * survival_rate)

    survivors =
      old
      |> Enum.sort_by(& &1.fitness, sorter)
      |> Enum.take(num_survivors)

    offspring ++ survivors
  end

  def uniform(parents, offspring, leftover, population_size, survival_rate) do
    old = parents ++ leftover
    num_survivors = floor(population_size * survival_rate)

    survivors =
      old
      |> misc().take_random(num_survivors)

    offspring ++ survivors
  end
end
