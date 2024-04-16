defmodule Types.Chromosome do
  require Arrays

  @type t :: %__MODULE__{
    genes: Arrays.t(),
    fitness: number(),
    normalized_fitness: number(),
    accumulated_fitness: number(),
    age: integer(),
    selection_probability: float(),
    snr: float(),
  }

  defstruct genes: Arrays.new([]),
            fitness: 0,
            normalized_fitness: 0,
            accumulated_fitness: 0,
            age: 0,
            selection_probability: 0,
            snr: 0
end
