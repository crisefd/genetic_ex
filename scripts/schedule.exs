defmodule Schedule do
  alias Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc

  @behaviour Problem
  @penalty -99999
  @weight 1 / 3
  @max_credits 18
  @credit_hours [3.0, 3.0, 3.0, 4.5, 3.0, 3.0, 3.0, 3.0, 4.5, 1.5]
  @difficulties [8.0, 9.0, 4.0, 3.0, 5.0, 2.0, 4.0, 2.0, 6.0, 1.0]
  @usefulnesses [8.0, 9.0, 6.0, 2.0, 8.0, 9.0, 1.0, 2.0, 5.0, 1.0]
  @interests [8.0, 8.0, 5.0, 9.0, 7.0, 2.0, 8.0, 2.0, 7.0, 10.0]

  @impl true
  def genotype(_) do
    genes =
      for(_ <- 1..10, do: Misc.random(0..1))
      |> Arrays.new()

    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes} = _solution) do
    schedule = Arrays.to_list(genes)

    total_fitness =
      [schedule, @difficulties, @usefulnesses, @interests]
      |> Enum.zip()
      |> Enum.map(fn {class, difficulty, usefulness, interest} ->
        class * @weight * (usefulness + interest - difficulty)
      end)
      |> Enum.sum()

    credits =
      schedule
      |> Enum.zip(@credit_hours)
      |> Enum.map(fn {class, credits} -> class * credits end)
      |> Enum.sum()

    if credits > @max_credits, do: @penalty, else: total_fitness
  end

  @impl true
  def terminate?(_, 1000, _), do: true
  def terminate?(_, _, _), do: false
end

Genetic.execute(Schedule)
|> IO.inspect()

# {_, stats} = Utilities.Stats.lookup(500)
# IO.inspect(stats, label: "Stats")
