defmodule ResinsertionTest do
  alias Types.Chromosome
  alias Toolbox.Reinsertion
  use ExUnit.Case
  import Mox
  doctest Reinsertion

  setup :verify_on_exit!

  test "Pure Reinsertion" do
    expected_new_population = offspring()
    actual_new_population = Reinsertion.pure(parents(), offspring(), leftover())
    assert expected_new_population == actual_new_population
  end

  test "Elitist Reinsertion" do
    population_size = 6
    optimization_type = :max
    survival_rate = 0.5

    actual_new_population =
      Reinsertion.elitist(
        parents(),
        offspring(),
        leftover(),
        population_size,
        optimization_type,
        survival_rate
      )

    expected_survivors =
      (parents() ++ leftover())
      |> Enum.sort_by(& &1.fitness, :desc)
      |> Enum.take(floor(population_size * survival_rate))

    expected_new_population =
      offspring() ++ expected_survivors

    assert expected_new_population == actual_new_population
  end

  test "Uniform Reinsertion" do
    population_size = 6
    survival_rate = 0.5
    num_survivors = floor(population_size * survival_rate)

    survivors =
      [
        Arrays.new([0, 2, 4, 6]),
        Arrays.new([8, 10, 12, 14]),
        Arrays.new([0, -2, -4, -6])
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes, fitness: Enum.sum(genes)}
      end)

    old = parents() ++ leftover()

    MiscMock
    |> expect(:take_random, fn ^old, ^num_survivors -> survivors end)

    expected_new_population = offspring() ++ survivors

    actual_new_population =
      Reinsertion.uniform(
        parents(),
        offspring(),
        leftover(),
        population_size,
        survival_rate
      )

    assert expected_new_population == actual_new_population
  end

  defp parents() do
    [
      Arrays.new([0, 2, 4, 6]),
      Arrays.new([8, 10, 12, 14]),
      Arrays.new([16, 18, 20, 22])
    ]
    |> Enum.map(fn genes ->
      %Chromosome{genes: genes, fitness: Enum.sum(genes)}
    end)
  end

  defp offspring() do
    [
      Arrays.new([0, 20, 40, 60]),
      Arrays.new([80, 100, 120, 140]),
      Arrays.new([160, 180, 200, 220]),
      Arrays.new([60, 80, 20, 100]),
      Arrays.new([120, 80, 40, 100]),
      Arrays.new([90, 92, 93, 94])
    ]
    |> Enum.map(fn genes ->
      %Chromosome{genes: genes, fitness: Enum.sum(genes)}
    end)
  end

  defp leftover() do
    [
      Arrays.new([0, -2, -4, -6]),
      Arrays.new([-8, -10, -12, -14]),
      Arrays.new([-16, -18, -20, -22])
    ]
    |> Enum.map(fn genes ->
      %Chromosome{genes: genes, fitness: Enum.sum(genes)}
    end)
  end
end
