defmodule TigerSimulation do
  alias Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc

  @behaviour Problem

  @tropic_scores [0.0, 3.0, 2.0, 1.0, 0.5, 1.0, -1.0, 0.0]
  @tundra_scores [1.0, 3.0, -2.0, -1.0, 0.5, 2.0, 1.0, 0.0]

  @impl true
  def genotype() do
    genes = for(_ <- 1..8, do: Misc.random(0..1)) |> Arrays.new()
    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: traits}) do
    traits
    |> Enum.zip(@tundra_scores)
    |> Enum.reduce(0, fn {trait, score}, sum -> trait * score + sum end)
  end

  @impl true
  def terminate?(_, generation, _) do
    generation === 200
  end

  def average_tiger(population) do
    num_tigers = Enum.count(population)

    [ages: age_sum, fits: fit_sum] =
      population
      |> Enum.reduce([ages: 0, fits: 0], fn chromosome, sums ->
        age_sum = Keyword.get(sums, :ages) + chromosome.age
        fit_sum = Keyword.get(sums, :fits) + chromosome.fitness

        [ages: age_sum, fits: fit_sum]
      end)

    avg_age = age_sum / num_tigers
    avg_fit = fit_sum / num_tigers

    avg_genes =
      population
      |> Enum.map(&Arrays.to_list(&1.genes))
      |> Enum.zip()
      |> Enum.map(&(Tuple.sum(&1) / num_tigers))
      |> Arrays.new()

    %Chromosome{genes: avg_genes, age: avg_age, fitness: avg_fit}
  end
end

# result =
Genetic.execute(TigerSimulation,
  population_size: 20,
  selection_rate: 0.9,
  mutation_rate: 0.1,
  logging: false
  # stats_functions: [average_tiger: &TigerSimulation.average_tiger/1]
)
|> IO.inspect()

trans_fun =
  fn {gen, stats} ->
    [gen, stats.mean_fitness]
  end

commands = [
  [:set, :title, "Mean fitness versus generation"],
  [:plot, "-", :with, :points]
]

Utilities.Stats.plot(trans_fun, commands)

# generations = Keyword.get(result, :generations)

# {_, data} = Utilities.Stats.lookup(div(generations, 2))
# IO.inspect(data, label: "Stats")

# genealogy = Utilities.Genealogy.get_tree()

# {:ok, dot} = Graph.Serializers.DOT.serialize(genealogy)

# path = "scripts/output/tiger_simulation.dot" |> Path.absname()

# dotfile =
#   with {:ok, dotfile} <- File.open(path, [:write]) do
#     dotfile
#   else
#     {:error, _} ->
#       :ok = File.touch(path, :erlang.universaltime())
#       {:ok, dotfile} = File.open(path, [:write])
#       dotfile
#   end

# :ok = IO.binwrite(dotfile, dot)
# :ok = File.close(dotfile)

Utilities.Stats.drop()
