defmodule SelectionTest do
  alias Types.Chromosome
  use ExUnit.Case
  doctest Selection

  test "Elitism Selection" do
    population =
      [
        [100, 500, 400, 300, 50],
        [130, 56, 78, 18, 13],
        [10, 25, 14, 32, 11],
        [1, 2, 3, 4, 5],
        [0, 0, 0, 0, 0],
        [-5, -2, -1, -3, -4],
        [-55, -22, -11, -33, -44]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    expected =
      population
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    actual = Selection.elitism(population)
    assert expected == actual
  end

  test "Roulette Selection with positive fitness values" do
    population =
      [1, 15, 23, 1, 5, 7, 8]
      |> Enum.map(fn fit -> %Chromosome{fitness: fit} end)

    expected = [0.171, 0.290, 0.377, 0.549, 0.706, 0.854, 1.0]
    actual = Selection.calculate_probabilities(population, 1.0)
    tolerance = 0.005

    assertion =
      expected
      |> Enum.zip(actual)
      |> Enum.map(fn {exp, act} -> abs(abs(exp) - abs(act)) < tolerance end)
      |> Enum.reduce(true, fn acceptable?, result -> acceptable? and result end)

    assert assertion
  end

  test "Roulette Selection with negative fitness values" do
    population =
      [-1, -15, -23, -1, -5, -7, -8]
      |> Enum.map(fn fit -> %Chromosome{fitness: fit} end)

    expected = [0.107, 0.280, 0.490, 0.598, 0.724, 0.859, 1.0]
    actual = Selection.calculate_probabilities(population, 1.0)
    tolerance = 0.005

    assertion =
      expected
      |> Enum.zip(actual)
      |> Enum.map(fn {exp, act} -> abs(abs(exp) - abs(act)) < tolerance end)
      |> Enum.reduce(true, fn acceptable?, result -> acceptable? and result end)

    assert assertion
  end
end
