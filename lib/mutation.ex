defmodule Mutation do
  alias Types.Chromosome

  def shuffle(chromosome) do
    new_genes =
      chromosome.genes
      |> Enum.shuffle()
      |> Arrays.new()

    %Chromosome{genes: new_genes}
  end

  def one_gene(chromosome, range) do
    size = Arrays.size(chromosome.genes)
    gene_index = Enum.random(0..(size - 1))
    base_gene = Arrays.get(chromosome.genes, gene_index)
    mutated_gene = Enum.random(range)

    if base_gene === mutated_gene do
      one_gene(chromosome, range)
    else
      new_genes =
        chromosome.genes
        |> Arrays.replace(gene_index, mutated_gene)

      %Chromosome{genes: new_genes}
    end
  end

  def all_genes(chromosome, range) do
    size = Arrays.size(chromosome.genes)

    new_genes =
      for(_ <- 1..size, do: Enum.random(range))
      |> Arrays.new()

    %Chromosome{genes: new_genes}
  end
end
