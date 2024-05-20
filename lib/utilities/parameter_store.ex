defmodule Utilities.ParameterStore do
  alias Toolbox.Selection
  alias Toolbox.Crossover
  alias Toolbox.Mutation
  alias Toolbox.Reinsertion
  alias Utilities.Misc

  @type optimization_type() :: :max | :min

  @type t :: %__MODULE__{
          population_size: integer(),
          mutation_rate: float(),
          selection_rate: float(),
          optimization_type: optimization_type(),
          logging_step: integer(),
          logging?: boolean(),
          cooling_rate: float(),
          survival_rate: float(),
          bounds_function: nil | function(),
          selection_function: function(),
          crossover_function: function(),
          mutation_function: function(),
          reinsert_function: function(),
          stats_functions: keyword(),
          parallelized_fitness_evaluation?: boolean(),
          parallelized_crossover?: boolean(),
          parallelized_mutate?: boolean(),
          logging?: boolean()
        }

  @default_stats_functions [
    min_fitness: &Misc.min_fitness/1,
    max_fitness: &Misc.max_fitness/1,
    mean_fitness: &Misc.mean_fitness/1,
    population_size: &Misc.count_chromosomes/1
  ]

  defstruct population_size: 100,
            mutation_rate: 0.05,
            selection_rate: 0.8,
            optimization_type: :max,
            logging_step: 10,
            cooling_rate: 0.8,
            survival_rate: 0.2,
            bounds_function: nil,
            selection_function: &Selection.elitist/3,
            crossover_function: &Crossover.one_point/1,
            mutation_function: &Mutation.scramble/1,
            reinsert_function: &Reinsertion.elitist/6,
            stats_functions: @default_stats_functions,
            parallelized_fitness_evaluation?: false,
            parallelized_crossover?: false,
            parallelized_mutate?: false,
            logging?: false
end