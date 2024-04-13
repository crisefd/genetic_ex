defmodule Genetic.OneMaxGA  do
require Integer

  def execute(chromo_size, pop_size, mutation_rate, debug \\ false) do
    fixed_chromo_size = fix_chromo_size(chromo_size)
    init_pop(fixed_chromo_size, pop_size)
    |> evolve(fixed_chromo_size, 0, mutation_rate, debug)
  end

  defp fix_chromo_size(size) when Integer.is_odd(size) do
    size + 1
  end

  defp fix_chromo_size(size), do: size

  defp init_pop(chromo_size, pop_size) do
    for _ <- 1..pop_size, do: (for _ <- 1..chromo_size, do: Enum.random(0..1))
  end

  defp evaluate(population) do
    population
    |> Enum.sort_by( &Enum.sum/1, :desc)
  end

  defp select(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(couples, size) do
    couples
    |> Enum.reduce([], fn {p1, p2}, acc ->
      cx_point = :rand.uniform(size)
      {{h1, t1}, {h2, t2}} = { Enum.split(p1, cx_point), Enum.split(p2, cx_point) }
      [h1 ++ t2, h2 ++ t1 | acc ]
    end)
  end

  def mutate(population, rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < rate  do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
     end)
  end

  defp evolve(population, size, generation, mutation_rate, debug) do
    best = Enum.max_by(population, &Enum.sum/1)
    best_fit = Enum.sum(best)
    if debug do
      IO.puts("Generation: #{generation}")
      IO.puts("Current best fitness: #{best_fit}")
    end
    if best_fit == size do
      %{best: best, best_fit: best_fit, generation: generation}
    else
      population
      |> evaluate()
      |> select()
      |> crossover(size)
      |> mutate(mutation_rate)
      |> evolve(size, generation + 1, mutation_rate, debug)
    end
  end

end
