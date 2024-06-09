defmodule Toolbox.Reinsertion do
  alias Types.Chromosome

  @type chromosome() :: Chromosome.t()
  @type array() :: Arrays.t()
  @type optimization_type() :: :max | :min

  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  @spec pure(list(chromosome()), list(chromosome()), list(chromosome())) :: list(chromosome())

  def pure(_parents, offspring, _leftover), do: offspring

  @spec elitist(
          list(chromosome()),
          list(chromosome()),
          list(chromosome()),
          integer(),
          optimization_type(),
          float()
        ) :: list(chromosome())

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

  @spec uniform(
          list(chromosome()),
          list(chromosome()),
          list(chromosome()),
          integer(),
          float()
        ) :: list(chromosome())

  def uniform(parents, offspring, leftover, population_size, survival_rate) do
    old = parents ++ leftover
    num_survivors = floor(population_size * survival_rate)

    survivors =
      old
      |> misc().take_random(num_survivors)

    offspring ++ survivors
  end
end
