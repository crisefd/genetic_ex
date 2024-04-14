defmodule Genetic do
  require Arrays

  @default_population_size 1000
  @default_mutation_rate 0.05
  @default_selection_chunk_size 2
  @default_evaluation_sorter :desc

  def execute(genotype, fitness_function, optimal_fitness, opts \\ []) do
    initialize_population(genotype, opts)
    |> evolve(optimal_fitness, fitness_function, 0, opts)
  end

  defp initialize_population(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evaluate(population, fitness_function, opts) do
    sorter = Keyword.get(opts, :evaluation_sorter, @default_evaluation_sorter)
    population
    |> Enum.sort_by(fitness_function, sorter)
  end

  defp select(population, opts) do
    selection_chunk_size = Keyword.get(opts, :selection_chunck_size, @default_selection_chunk_size)
    population
    |> Enum.chunk_every(selection_chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(couples, opts) do
    couples
    |> Enum.reduce([], fn {p1, p2}, population ->
      size = Arrays.size(p1)
      cx_point = :rand.uniform(size)
      {{l1, r1}, {l2, r2}} = { split(p1, cx_point, size), split(p2, cx_point, size) }
      [  Arrays.concat(l1, r2), Arrays.concat(l2, r1) | population ]
    end)
  end

  defp mutate(population, opts) do
    mutation_rate = Keyword.get(opts, :mutation_rate, @default_mutation_rate)
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate  do
        chromosome
        |> Enum.shuffle()
        |> Arrays.new()
      else
        chromosome
      end
    end)
  end

  defp evolve(population, optimal_fitness, fitness_function, generation, opts) do
    sorted_population =
      population
      |> evaluate(fitness_function, opts)
    best = hd(sorted_population)
    best_fit = fitness_function.(best)
    logging = Keyword.get(opts, :logging, true)

    if logging do
      IO.puts("Generation: #{generation}")
      IO.puts("Current best fitness: #{best_fit}")
    end

    if optimal_fitness === best_fit do
      %{best: best, best_fit: best_fit, generation: generation}
    else
      sorted_population
      |> select(opts)
      |> crossover(opts)
      |> mutate(opts)
      |> evolve(optimal_fitness, fitness_function,  generation + 1, opts)
    end
  end


  defp split(chromosome, cx_point, size) do
    right_side_amount = size - cx_point
    left_side_amount = size - right_side_amount
    { Arrays.slice(chromosome, 0, left_side_amount),
      Arrays.slice(chromosome, cx_point, right_side_amount) }
  end

end
