defmodule Utilities do

  def sum(genes) do
    Arrays.reduce(genes, 0, fn val, acc -> val + acc  end)
  end

  def split(genes, cx_point) do
    size = Arrays.size(genes)
    right_side_amount = size - cx_point
    left_side_amount = size - right_side_amount
    { Arrays.slice(genes, 0, left_side_amount),
      Arrays.slice(genes, cx_point, right_side_amount) }
  end

  def minmax_fitness([first | population]) do
    population
    |> Arrays.reduce({first.fitness, first.fitness}, fn chromosome, {min, max} ->
      new_max =  if chromosome.fitness > max, do: chromosome.fitness, else: max
      new_min = if chromosome.fitness < min, do: chromosome.fitness, else: min
      {new_min, new_max}
    end)
  end

end
