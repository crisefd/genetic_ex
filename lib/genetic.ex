defmodule Genetic do
  alias Types.Chromosome
  require Utilities
  require Arrays

  @default_population_size 1000
  @default_mutation_rate 0.05
  @default_optimization :max

  def execute(problem, opts \\ []) do
    initialize_population(&problem.genotype/0, opts)
    |> evolve(problem, 0, opts)
  end

  defp initialize_population(genotype, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    for _ <- 1..population_size, do: genotype.()
  end

  defp evaluate(population, fitness_function, opts) do
    population_size = Keyword.get(opts, :population_size, @default_population_size)
    optimization = Keyword.get(opts, :optimization, @default_optimization)
    sorter = if optimization == :max, do: :desc, else: :asc
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(fitness_function, sorter)
    |> Enum.slice(0, population_size)
  end

  defp select(population, selection_function, opts) do
    selection_function.(population, opts)
  end

  defp crossover(pairs, population, _opts) do
    pairs
    |> Enum.reduce(population,
      fn {p1, p2}, new_population ->
        size = Arrays.size(p1.genes)
        cx_point = :rand.uniform(size)
        {{l1, r1}, {l2, r2}} = { Utilities.split(p1.genes, cx_point), Utilities.split(p2.genes, cx_point) }
        c1 = %Chromosome{ p1 | genes:  Arrays.concat(l1, r2) }
        c2 = %Chromosome{ p2 | genes:  Arrays.concat(l2, r1) }
        [ c1, c2 | new_population ]
      end)
  end

  defp mutate(population, opts) do
    mutation_rate = Keyword.get(opts, :mutation_rate, @default_mutation_rate)
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < mutation_rate  do
        mutated_genes =
          chromosome.genes
          |> Enum.shuffle()
          |> Arrays.new()
        %Chromosome{ chromosome | genes: mutated_genes }
      else
        chromosome
      end
    end)
  end

  defp evolve(population, problem, generation, opts) do
    sorted_population =
      population
      |> evaluate(&problem.fitness_function/1, opts)

    best = hd(sorted_population)

    log(best, generation, opts)

    if problem.terminate?(sorted_population) do
      population_size = Keyword.get(opts, :population_size, @default_population_size)
      chromosome_size =  best.genes |> Arrays.size()
      %{
        evaluations: population_size * chromosome_size * generation,
        generations: generation,
        best: best.genes |> Arrays.to_list(),
        best_fitness: best.fitness,
      }
    else
      sorted_population
      |> select(&problem.selection_function/2, opts)
      |> crossover(sorted_population, opts)
      |> mutate(opts)
      |> evolve(problem, generation + 1, opts)
    end
  end

  defp log(best, generation, opts) do
    logging = Keyword.get(opts, :logging, true)
    if logging do
      IO.puts("Generation: #{generation}")
      IO.puts("Current best fitness: #{best.fitness}")
    end
  end

end
