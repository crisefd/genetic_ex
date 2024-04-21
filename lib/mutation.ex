defmodule Mutation do
  @moduledoc """
     The Mutation module contains some of the most commonly used mutation strategies for genetic algorithms
  """

  alias Types.Chromosome

  @type chromosome() :: Chromosome.t()
  @type range() :: Range.t()

  @spec misc() :: module()
  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  @spec shuffle(chromosome :: chromosome()) :: chromosome()

  @doc """
    Shuffles the list of genes of a chromosome
  """
  def shuffle(chromosome) do
    new_genes =
      chromosome.genes
      |> misc().shuffle()
      |> Arrays.new()

    %Chromosome{genes: new_genes}
  end

  @spec one_gene(chromosome :: chromosome(), range :: range()) :: chromosome()

  @doc """
    Takes a chromosome and mutates one of its genes at random
  """
  def one_gene(chromosome, range) do
    size = Arrays.size(chromosome.genes)
    gene_index = misc().random(0..(size - 1))
    base_gene = Arrays.get(chromosome.genes, gene_index)
    mutated_gene = misc().random(range)

    if base_gene === mutated_gene do
      one_gene(chromosome, range)
    else
      new_genes =
        chromosome.genes
        |> Arrays.replace(gene_index, mutated_gene)

      %Chromosome{genes: new_genes}
    end
  end

  @spec all_genes(chromosome :: chromosome(), range :: range()) :: chromosome()

  @doc """
  Takes a chromosome and mutates all of its genes
  """
  def all_genes(chromosome, range) do
    size = Arrays.size(chromosome.genes)

    new_genes =
      for(_ <- 1..size, do: misc().random(range))
      |> Arrays.new()

    %Chromosome{genes: new_genes}
  end
end
