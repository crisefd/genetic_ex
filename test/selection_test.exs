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
    chromo0 = %Chromosome{genes: [100, 500, 400, 300, 50] |> Arrays.new(), fitness: 1350}
    chromo1 = %Chromosome{genes: [130, 56, 78, 18, 13] |> Arrays.new(), fitness: 295}
    chromo2 = %Chromosome{genes: [10, 25, 14, 32, 11] |> Arrays.new(), fitness: 92}
    chromo3 = %Chromosome{genes: [1, 2, 3, 4, 5] |> Arrays.new(), fitness: 15}
    chromo4 = %Chromosome{genes: [0, 0, 0, 0, 0] |> Arrays.new(), fitness: 0}
    chromo5 = %Chromosome{genes: [-5, -2, -1, -3, -4] |> Arrays.new(), fitness: -15}
    chromo6 = %Chromosome{genes: [-55, -22, -11, -33, -44] |> Arrays.new(), fitness: -165}

    population =
      [
        chromo0,
        chromo1,
        chromo2,
        chromo3,
        chromo4,
        chromo5,
        chromo6
      ]

    selection_rate = 0.5
    population_size = Enum.count(population)
    optimization = :max

    MiscMock
    |> expect(:take_random, fn _, _ -> [chromo0, chromo6] end)
    |> expect(:take_random, fn _, _ -> [chromo1, chromo2] end)
    |> expect(:take_random, fn _, _ -> [chromo3, chromo4] end)
    |> expect(:take_random, fn _, _ -> [chromo5, chromo5] end)

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
      |> Enum.reverse()

    actual_parents =
      population
      |> Selection.tournament(population_size, selection_rate, optimization)

    assert expected_parents == actual_parents
  end

  test "SUS selection" do
    chromo0 = %Chromosome{genes: [100, 500, 400, 300, 50] |> Arrays.new(), fitness: 1350}
    chromo1 = %Chromosome{genes: [130, 56, 78, 18, 13] |> Arrays.new(), fitness: 295}
    chromo2 = %Chromosome{genes: [10, 25, 14, 32, 11] |> Arrays.new(), fitness: 92}
    chromo3 = %Chromosome{genes: [1, 2, 3, 4, 5] |> Arrays.new(), fitness: 15}
    chromo4 = %Chromosome{genes: [0, 0, 0, 0, 0] |> Arrays.new(), fitness: 0}
    chromo5 = %Chromosome{genes: [-5, -2, -1, -3, -4] |> Arrays.new(), fitness: -15}
    chromo6 = %Chromosome{genes: [-55, -22, -11, -33, -44] |> Arrays.new(), fitness: -165}

    population =
      [
        chromo0,
        chromo1,
        chromo2,
        chromo3,
        chromo4,
        chromo5,
        chromo6
      ]

    selection_rate = 0.5
    population_size = Enum.count(population)

    MiscMock
    |> expect(:random, fn _ -> 2000 end)
    |> expect(:minmax_fitness, &Misc.minmax_fitness/1)

    expected_parents =
      [
        [1, 2, 3, 4, 5],
        [10, 25, 14, 32, 11],
        [130, 56, 78, 18, 13],
        [100, 500, 400, 300, 50]
      ]
      |> Enum.map(fn genes ->
        %Chromosome{genes: genes |> Arrays.new(), fitness: Enum.sum(genes)}
      end)

    actual_parents =
      population
      |> Selection.stochastic_universal_sampling(population_size, selection_rate)

    assert expected_parents == actual_parents
  end
end
