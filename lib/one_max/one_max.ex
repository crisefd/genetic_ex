defmodule Genetic.OneMaxGA  do
require Integer
require Arrays

  def execute(chromo_size, pop_size, mutation_rate, debug \\ false) do
    fixed_chromo_size = fix_chromo_size(chromo_size)
    init_pop(fixed_chromo_size, pop_size)
    |> evolve(fixed_chromo_size, 0, mutation_rate, debug)
  end

  defp fix_chromo_size(size) when Integer.is_odd(size) do
    size + 1
  end

  defp fix_chromo_size(size), do: size

  defp find_best(population) do
    population
    |> Enum.reduce(%{best: nil, best_fit: -1}, fn chromo, result ->
        fit = sum(chromo)
        if fit > result.best_fit do
          %{best: chromo, best_fit: fit}
        else
          result
        end
    end)
  end

  defp sum(chromosome) do
    chromosome
    |> Arrays.reduce(0, fn val, acc -> val + acc  end)
  end

  defp split(chromosome, cx_point, size) do
    right_side_amount = size - cx_point
    left_side_amount = size - right_side_amount
    { Arrays.slice(chromosome, 0, left_side_amount),
      Arrays.slice(chromosome, cx_point, right_side_amount) }
  end

  defp init_pop(chromo_size, pop_size) do
    for _ <- 1..pop_size, do: Arrays.new(for _ <- 1..chromo_size, do: Enum.random(0..1))
  end

  defp evaluate(population) do
    population
    |> Enum.sort_by( &sum/1, :desc)
  end

  defp select(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp crossover(couples, size) do
    couples
    |> Enum.reduce([], fn {p1, p2}, population ->
      cx_point = :rand.uniform(size)
      {{l1, r1}, {l2, r2}} = { split(p1, cx_point, size), split(p2, cx_point, size) }
      [  Arrays.concat(l1, r2), Arrays.concat(l2, r1) | population ]

    end)
  end

  defp mutate(population, rate) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < rate  do
        Arrays.new(Enum.shuffle(chromosome))
      else
        chromosome
      end
    end)
  end

  defp evolve(population, size, generation, mutation_rate, debug) do
    %{best: best, best_fit: best_fit} = find_best(population)
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
