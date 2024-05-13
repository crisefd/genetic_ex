defmodule Behaviours.Problem do
  alias Types.Chromosome

  @moduledoc """
    Genetic algorithm's Problem module.
    It describes the template for how all the particulars of a GA should be implemented
  """

  @type chromosome() :: Chromosome.t()
  @type population() :: list(chromosome())
  @type pair() :: {chromosome(), chromosome()}
  @type bound() :: {number(), number()}

  @doc """
    Randomly creates a new chromosome to initialize the population
  """
  @callback genotype(bounds :: list(bound())) :: chromosome()

  @doc """
    It tells you how good a solution (chromosome) is
  """
  @callback fitness_function(solution :: chromosome()) :: number()

  @doc """
    Decides when the algorithm should stop running. You can use the number of generation, temperature or fitness
  """
  @callback terminate?(
              chromosomes :: population(),
              generation :: integer(),
              temperature :: number()
            ) :: boolean()
end
