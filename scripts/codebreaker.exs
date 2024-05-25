defmodule Codebreaker do
  alias Behaviours.Problem
  alias Types.Chromosome
  alias Utilities.Misc
  import Bitwise

  @behaviour Problem

  @bit_range 1..64

  @impl true
  def genotype(_) do
    %Chromosome{
      genes: for(_ <- @bit_range, do: Enum.random(0..1)) |> Arrays.new()
    }
  end

  @impl true
  def fitness_function(solution) do
    target = "ILoveGeneticAlgorithms"
    encrypted = ~c"LIjs`B`k`qlfDibjwlqmhv"

    cipher =
      fn word, key ->
        word
        |> Enum.map(fn char ->
          bxor(char, key) |> rem(32768)
        end)
      end

    key =
      solution.genes
      |> Arrays.map(&Integer.to_string(&1))
      |> Enum.join("")
      |> String.to_integer(2)

    guess = List.to_string(cipher.(encrypted, key))
    String.jaro_distance(target, guess)
  end

  @impl true
  def terminate?([best | _], generation, _) do
    best.fitness == 1 || generation == 50_000
  end
end

Genetic.execute(Codebreaker)
|> IO.inspect()
