defmodule Types.Chromosome do
  require Arrays

  @type t :: %__MODULE__{
    genes: Arrays.t(),
    fitness: number(),
    acc_fitness: number(),
    age: integer(),
    select_prob: float(),
    snr: float(),
  }

  defstruct genes: Arrays.new([]),
            fitness: 0,
            acc_fitness: 0,
            age: 0,
            select_prob: 0,
            snr: 0
end
