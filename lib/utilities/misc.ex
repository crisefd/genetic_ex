defmodule Utilities.Misc do
  @behaviour Behaviours.Misc

  def random(mean, variance), do: :rand.normal(mean, variance)

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

  def get_cut_points(num_genes) do
    cut_point1 = random(1..(num_genes - 2))
    cut_point2 = random(1..(num_genes - 2))

    if cut_point1 != cut_point2 do
      if cut_point1 < cut_point2 do
        {cut_point1, cut_point2}
      else
        {cut_point2, cut_point1}
      end
    else
      get_cut_points(num_genes)
    end
  end
end
