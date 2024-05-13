defmodule Test do
  alias Types.Chromosome
  alias Utilities.Misc
  @behaviour Behaviours.Problem

  @impl true
  def genotype(_) do
    genes = for(_ <- 1..100, do: Misc.random(0..1)) |> Arrays.new()
    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: genes}) do
    Enum.sum(genes)
  end

  @impl true
  def terminate?(_, generation, _) do
    generation == 1
  end
end

defmodule Profiler do
  import ExProf.Macro

  def do_analyze do
    profile do
      Genetic.execute(Test, survival_rate: 0.3)
    end
  end

  def run do
    {records, _} = do_analyze()
    total_percent = records |> Enum.reduce(0.0, &(&1.percent + &2))
    IO.inspect(total_percent, label: "Total Percent")
  end
end

Profiler.run()
