defmodule Types.Chromosome do
  @type t :: %__MODULE__{
          id: integer(),
          genes: Arrays.t(),
          fitness: number(),
          age: integer()
        }

  defstruct genes: Arrays.new([]),
            fitness: 0,
            age: 0,
            id: Base.encode16(:crypto.strong_rand_bytes(64))

  defimpl Inspect, for: Types.Chromosome do
    import Inspect.Algebra

    def inspect(chromosome, _opts) do
      genes = chromosome.genes |> Arrays.to_list()

      concat([
        "\n",
        "\t Fitness: #{chromosome.fitness}",
        "\n",
        "\t Age: #{chromosome.age}",
        "\n",
        "\t Genes: #{inspect(genes)}",
        "\n",
        "\t ID: #{chromosome.id}",
        "\n"
      ])
    end
  end
end
