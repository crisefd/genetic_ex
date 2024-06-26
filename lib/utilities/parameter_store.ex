defmodule Utilities.ParameterStore do
  alias Toolbox.Selection
  alias Toolbox.Crossover
  alias Toolbox.Mutation
  alias Toolbox.Reinsertion
  alias Utilities.Misc

  @type optimization_type() :: :max | :min
  @type array() :: Arrays.t()

  @type t :: %__MODULE__{
          population_size: integer(),
          chromosome_size: integer(),
          discrete: boolean(),
          mutation_rate: float(),
          selection_rate: float(),
          optimization_type: optimization_type(),
          logging_step: integer(),
          logging?: boolean(),
          cooling_rate: float(),
          survival_rate: float(),
          selection_function: function(),
          crossover_function: function(),
          mutation_function: function(),
          reinsert_function: function(),
          stats_functions: keyword(),
          parallelize_fitness_evaluation?: boolean(),
          parallelize_crossover?: boolean(),
          parallelize_mutate?: boolean(),
          logging?: boolean()
        }

  @default_stats_functions [
    min_fitness: &Misc.min_fitness/1,
    max_fitness: &Misc.max_fitness/1,
    mean_fitness: &Misc.mean_fitness/1,
    population_size: &Misc.count_chromosomes/1
  ]

  defstruct population_size: 100,
            chromosome_size: 0,
            discrete: false,
            mutation_rate: 0.05,
            selection_rate: 0.8,
            optimization_type: :max,
            logging_step: 10,
            cooling_rate: 0.8,
            survival_rate: 0.2,
            selection_function: &Selection.elitist/3,
            crossover_function: &Crossover.one_point/1,
            mutation_function: &Mutation.scramble/1,
            reinsert_function: &Reinsertion.elitist/6,
            stats_functions: @default_stats_functions,
            parallelize_fitness_evaluation?: false,
            parallelize_crossover?: false,
            parallelize_mutate?: false,
            logging?: false
end
