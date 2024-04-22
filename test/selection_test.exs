defmodule SelectionTest do
  alias Types.Chromosome
  use ExUnit.Case
  import Mox
  doctest Selection

  setup :verify_on_exit!

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

    selection_rate = 0.5
    population_size = 7

    expected_parents =
      [
        [100, 500, 400, 300, 50],
        [130, 56, 78, 18, 13],
        [10, 25, 14, 32, 11],
        [1, 2, 3, 4, 5]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    actual_parents = Selection.elitism(population, population_size, selection_rate)
    assert expected_parents == actual_parents
  end

  test "Roulette Selection with positive fitness values" do
    population =
      [
        [100, 500, 400, 300, 50],
        [130, 56, 78, 18, 13],
        [10, 25, 14, 32, 11],
        [5, 12, 11, 33, 14],
        [15, 2, 1, 3, 4],
        [1, 2, 3, 4, 5],
        [0, 0, 0, 0, 0]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    ## expected_probs = [0.07924041730160591, 0.2203141483999531, 0.37328566404876334,
    ## 0.5272535458914547, 0.6841519165396788, 0.8416363849490094, 1.0]
    MiscMock
    |> expect(:shuffle, & &1)
    |> expect(:minmax_fitness, &Misc.minmax_fitness/1)
    |> expect(:random, fn -> 0.5 end)
    |> expect(:random, fn -> 0.6 end)
    |> expect(:random, fn -> 0.1 end)
    |> expect(:random, fn -> 0.7 end)

    selection_rate = 0.5
    population_size = 7

    expected_parents =
      [
        [1, 2, 3, 4, 5],
        [130, 56, 78, 18, 13],
        [15, 2, 1, 3, 4],
        [5, 12, 11, 33, 14]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    actual_parents = Selection.roulette(population, population_size, selection_rate)

    assert expected_parents == actual_parents
  end

  test "Roulette Selection with negative fitness values" do
    population =
      [
        [0, 0, 0, 0, 0],
        [-1, -2, -3, -4, -5],
        [-15, -2, -1, -3, -4],
        [-5, -12, -11, -33, -14],
        [-10, -25, -14, -32, -11],
        [-130, -56, -78, -18, -13],
        [-100, -500, -400, -300, -50]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    selection_rate = 0.5
    population_size = 7

    MiscMock
    |> expect(:shuffle, & &1)
    |> expect(:minmax_fitness, &Misc.minmax_fitness/1)
    |> expect(:random, fn -> 0.5 end)
    |> expect(:random, fn -> 0.3 end)
    |> expect(:random, fn -> 0.1 end)
    |> expect(:random, fn -> 0.7 end)

    # expected probabilities [0.11947684694238246, 0.24027925061859312, 0.3619653587840226,
    #  0.4880699893955461, 0.6156769176387415, 0.7612230470130787, 1.0]

    expected_parents =
      [
        [-130, -56, -78, -18, -13],
        [0, 0, 0, 0, 0],
        [-15, -2, -1, -3, -4],
        [-10, -25, -14, -32, -11]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    actual_parents = Selection.roulette(population, population_size, selection_rate)

    assert expected_parents == actual_parents
  end

  test "Tournament Selection" do
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

    selection_rate = 0.5
    population_size = Enum.count(population)
    optimization = :max

    MiscMock
    |> expect(:random, fn _ -> 0 end)
    |> expect(:random, fn _ -> 6 end)
    |> expect(:random, fn _ -> 1 end)
    |> expect(:random, fn _ -> 2 end)
    |> expect(:random, fn _ -> 3 end)
    |> expect(:random, fn _ -> 4 end)
    |> expect(:random, fn _ -> 5 end)
    |> expect(:random, fn _ -> 5 end)

    expected_parents =
      [
        [-5, -2, -1, -3, -4],
        [1, 2, 3, 4, 5],
        [130, 56, 78, 18, 13],
        [100, 500, 400, 300, 50]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    actual_parents =
      population
      |> Selection.tournament(population_size, selection_rate, optimization)

    assert expected_parents == actual_parents
  end
end
