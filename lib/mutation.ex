defmodule Mutation do

  def shuffle(genes) do
    genes
    |> Enum.shuffle()
    |> Arrays.new()
  end

  def one_gene(genes, range) do
    size = Arrays.size(genes)
    gene_index = Enum.random(0..(size - 1))
    mutated_gene = Enum.random(range)
    genes
    |> Arrays.replace(gene_index, mutated_gene)
  end

  def all_genes(genes, range) do
    size = Arrays.size(genes)
    Enum.take_random(range, size)
    |> Arrays.new()
  end

end
