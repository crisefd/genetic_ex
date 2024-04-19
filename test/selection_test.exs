defmodule SelectionTest do
  alias Types.Chromosome
  use ExUnit.Case
  doctest Selection

  setup_all do
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

    {:ok, population: population}
  end

  test "Elitism Selection", state do
    expected =
      state[:population]
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)

    actual = Selection.elitism(state[:population])
    assert expected == actual
  end
end
