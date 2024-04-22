defmodule Misc do
  @behaviour Behaviours.Misc

  def random(), do: :rand.uniform()

  def random(range), do: Enum.random(range)

  def take_random(enum, count), do: Enum.take_random(enum, count)

  def shuffle(list), do: Enum.shuffle(list)

  def weighted_sum(vals, factors) do
    vals
    |> Enum.zip(factors)
    |> Enum.map(fn {v, f} -> v * f end)
    |> Enum.sum()
  end

  def sum(genes) do
    Arrays.reduce(genes, 0, fn val, acc -> val + acc end)
  end

  def split(genes, cx_point) do
    size = Arrays.size(genes)
    right_side_amount = size - cx_point
    left_side_amount = size - right_side_amount
    {Arrays.slice(genes, 0, left_side_amount), Arrays.slice(genes, cx_point, right_side_amount)}
  end

  def minmax_fitness([first | population]) do
    population
    |> Enum.reduce({first.fitness, first.fitness}, fn chromosome, {min, max} ->
      new_max = if chromosome.fitness > max, do: chromosome.fitness, else: max
      new_min = if chromosome.fitness < min, do: chromosome.fitness, else: min
      {new_min, new_max}
    end)
  end
end
