defmodule TetrisInterface do
  use Agent

  @me __MODULE__

  def start_link(path_to_tetris_rom) do
    game =
      Alex.new()
      |> Alex.set_option(:display_screen, true)
      |> Alex.set_option(:sound, true)
      |> Alex.set_option(:random_seed, 123)
      |> Alex.load(path_to_tetris_rom)

    Agent.start_link(fn -> game end, name: @me)
  end
end

defmodule Tetris do
  alias Types.Chromosome
  alias Utilities.Misc
  @behaviour Behaviours.Problem

  @impl true
  def genotype(_) do
    game = Agent.get(TetrisInterface, & &1)
    genes = for(_ <- 1..1000, do: Misc.random(game.legal_actions)) |> Arrays.new()
    %Chromosome{genes: genes}
  end

  @impl true
  def fitness_function(%Chromosome{genes: actions}) do
    game = Agent.get(TetrisInterface, & &1)

    new_game =
      actions
      |> Arrays.reduce(game, fn action, state -> Alex.step(state, action) end)

    reward = new_game.reward

    Alex.reset(new_game)

    reward
  end

  @impl true
  def terminate?(_, generation, _) do
    generation == 5
  end
end

TetrisInterface.start_link("priv/tetris.bin")

Genetic.execute(Tetris, population_size: 10, logging: false) |> IO.inspect(label: "Result")
