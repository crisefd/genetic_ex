defmodule Genetic do
  alias Types.Chromosome
  require Arrays

  @default_population_size 1000
  @default_mutation_rate 0.05
  @default_selection_chunk_size 2
  @default_evaluation_sorter :desc

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
    sorter = Keyword.get(opts, :evaluation_sorter, @default_evaluation_sorter)
    population
    |> Enum.map(fn chromosome ->
      fitness = fitness_function.(chromosome)
      age = chromosome.age + 1
      %Chromosome{chromosome | fitness: fitness, age: age}
    end)
    |> Enum.sort_by(fitness_function, sorter)
    |> Enum.slice(0, population_size)
  end

  defp select(population, opts) do
    selection_chunk_size = Keyword.get(opts, :selection_chunck_size, @default_selection_chunk_size)
    population
    |> Enum.chunk_every(selection_chunk_size)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(couples, population, opts) do
    couples
    |> Enum.reduce(population,
      fn {p1, p2}, new_population ->
        size = Arrays.size(p1.genes)
        cx_point = :rand.uniform(size)
        {{l1, r1}, {l2, r2}} = { split(p1.genes, cx_point, size), split(p2.genes, cx_point, size) }
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
    best_fit = best.fitness
    logging = Keyword.get(opts, :logging, true)

    if logging do
      IO.puts("Generation: #{generation}")
      IO.puts("Current best fitness: #{best_fit}")
    end

    if problem.terminate?(population) do
      %{best: best, best_fit: best_fit, generation: generation}
    else
      sorted_population
      |> select(opts)
      |> crossover(sorted_population, opts)
      |> mutate(opts)
      |> evolve(problem,  generation + 1, opts)
    end
  end

  defp split(genes, cx_point, size) do
    right_side_amount = size - cx_point
    left_side_amount = size - right_side_amount
    { Arrays.slice(genes, 0, left_side_amount),
      Arrays.slice(genes, cx_point, right_side_amount) }
  end

end
