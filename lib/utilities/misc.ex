defmodule Utilities.Misc do
  @behaviour Behaviours.Misc

  @type array() :: Arrays.t()

  @impl true
  def random(mean, variance), do: :rand.normal(mean, variance)

  @impl true
  def random(), do: :rand.uniform()

  @impl true
  def random(range), do: Enum.random(range)

  @impl true
  def take_random(enum, count), do: Enum.take_random(enum, count)

  @impl true
  def shuffle(list), do: Enum.shuffle(list)

  @impl true
  def weighted_sum(vals, factors) do
    vals
    |> Enum.zip(factors)
    |> Enum.map(fn {v, f} -> v * f end)
    |> Enum.sum()
  end

  @impl true
  def sum(genes) do
    Arrays.reduce(genes, 0, fn val, acc -> val + acc end)
  end

  @impl true
  def split(genes, cx_point) do
    size = Arrays.size(genes)
    right_side_amount = size - cx_point
    left_side_amount = size - right_side_amount
    {Arrays.slice(genes, 0, left_side_amount), Arrays.slice(genes, cx_point, right_side_amount)}
  end

  @impl true
  def pmap(collection, function) do
    collection
    |> Enum.map(&Task.async(function.(&1)))
    |> Enum.map(&Task.await(&1))
  end

  @impl true
  def minmax_fitness([first | population]) do
    population
    |> Enum.reduce({first.fitness, first.fitness}, fn chromosome, {min, max} ->
      new_max = if chromosome.fitness > max, do: chromosome.fitness, else: max
      new_min = if chromosome.fitness < min, do: chromosome.fitness, else: min
      {new_min, new_max}
    end)
  end

  @impl true
  def min_fitness(population) do
    Enum.min_by(population, fn chromosome -> chromosome.fitness end).fitness
  end

  @impl true
  def max_fitness(population) do
    Enum.max_by(population, fn chromosome -> chromosome.fitness end).fitness
  end

  @impl true
  def mean_fitness(population) do
    population
    |> Enum.reduce(0, fn chromosome, sum -> chromosome.fitness + sum end)
    |> Kernel./(Enum.count(population))
  end

  @impl true
  def count_chromosomes(population), do: Enum.count(population)

  @impl true
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

  @spec load_array(binary()) :: array()

  def load_array(filename) do
    "priv/taguchi_orthogonal_arrays/#{filename}.csv"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Arrays.new()
    end)
    |> Arrays.new()
  end

  def get_nil() do
    nil
  end
end
