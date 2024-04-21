defmodule Types.Chromosome do
  @type t :: %__MODULE__{
          genes: Arrays.t(),
          fitness: number(),
          age: integer()
        }

  defstruct genes: Arrays.new([]),
            fitness: 0,
            age: 0

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
        "\n"
      ])
    end
  end
end
