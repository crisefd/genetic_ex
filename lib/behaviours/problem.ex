defmodule Behaviours.Problem do
  alias Types.Chromosome

  @moduledoc """
    Genetic algorithm's Problem module.
    It describes the template for how all the particulars of a GA should be implemented
  """

  @type chromosome() :: Chromosome.t()
  @type population() :: list(chromosome())
  @type pair :: {chromosome(), chromosome()}

  @doc """
    Randomly creates a new chromosome to initialize the population
  """
  @callback genotype() :: chromosome()

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

  @doc """
    Chooses a subset of the list of chromosomes for crossover and returns a list of parent pairs
  """
  @callback selection_function(chromosomes :: population(), opts :: list()) ::
              list(pair())

  @doc """
    Reproduction operator. It takes parent pairs, produces offspring with them and can later add them to the list of chromosomes,
    If the implementation temporarily increases the size of the population the evaluate() subroutine will take care of downsizing the population
  """
  @callback crossover_function(parent_pairs :: list(pair()), chromosomes :: population()) ::
              population()

  @doc """
    Mutation operator. It takes the list of chromosomes and mutates some of their's genes without
    changing the size of the population
  """
  @callback mutation_function(chromosomes :: population(), mutation_rate :: number()) ::
              population()
end
