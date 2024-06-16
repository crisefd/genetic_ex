defmodule Problems.Htga do
  @behaviour Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.BenchmarkFunctions

  @impl true
  def genotype() do
    {lower_bounds, upper_bounds} = domain()

    genes =
      0..(dimension() - 1)
      |> Enum.map(fn i ->
        range = lower_bounds[i]..upper_bounds[i]
        Enum.random(range)
      end)
      |> Arrays.new()

    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(solution) do
    {_, _, fun} = BenchmarkFunctions.get(:schwefel)
    fun.(solution.genes)
  end

  @impl true
  def terminate?([best | _chromosomes], generation, _temperature) do
    {_, get_minima, _} = BenchmarkFunctions.get(:schwefel)
    minima = get_minima.(dimension())
    best.fitness === minima || generation == 10_000
  end

  @impl true
  def domain() do
    {{lower_bound, upper_bound}, _, _} = BenchmarkFunctions.get(:schwefel)
    lower_bounds = for _ <- 0..(dimension() - 1), do: lower_bound
    upper_bounds = for _ <- 0..(dimension() - 1), do: upper_bound
    {lower_bounds |> Arrays.new(), upper_bounds |> Arrays.new()}
  end

  def select_taguchi_array() do
    max_num_factors =
      [8, 16, 32, 64, 128, 256, 512, 1024]
      |> Enum.find(nil, fn num_factors ->
        dimension() <= num_factors
      end)

    Utilities.Misc.load_array("L#{max_num_factors}")
  end

  def dimension(), do: 30
end
