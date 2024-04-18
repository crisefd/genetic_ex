defmodule Types.Chromosome do
  @type t :: %__MODULE__{
          genes: Arrays.t(),
          fitness: number(),
          normalized_fitness: number(),
          accumulated_fitness: number(),
          age: integer(),
          selection_probability: float(),
          snr: float()
        }

  defstruct genes: Arrays.new([]),
            fitness: 0,
            normalized_fitness: 0,
            accumulated_fitness: 0,
            age: 0,
            selection_probability: 0,
            snr: 0

  defimpl Inspect, for: Types.Chromosome do
    import Inspect.Algebra

    def inspect(chromosome, _opts) do
      genes = chromosome.genes |> Arrays.to_list() |> List.to_string()

      # genes = if String.length(full_genes) > 25, do: String.slice(full_genes, 0, 25) <> "\n...", else: full_genes
      concat([
        "\n",
        "\t Fitness: #{chromosome.fitness}",
        "\n",
        "\t Age: #{chromosome.age}",
        "\n",
        "\t Genes: #{genes}",
        "\n"
      ])
    end
  end
end
