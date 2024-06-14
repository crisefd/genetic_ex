optimization_type = :min

taguchi_array = Problems.Htga.select_taguchi_array()

crossover_function = fn parents, _ ->
  Problems.Htga.taguchi_crossover(parents, taguchi_array, optimization_type)
end

results =
  Genetic.execute(
    Problems.Htga,
    %Utilities.ParameterStore{
      parallelize_fitness_evaluation?: false,
      parallelize_crossover?: false,
      parallelize_mutate?: false,
      crossover_function: crossover_function,
      optimization_type: optimization_type
    }
  )

IO.inspect(results, label: "Results")
