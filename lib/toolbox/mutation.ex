defmodule Toolbox.Mutation do
  @moduledoc """
     The Mutation module contains some of the most commonly used mutation strategies for genetic algorithms
  """

  alias Types.Chromosome

  @type chromosome() :: Chromosome.t()
  @type range() :: Range.t()
  @type array() :: Arrays.t()

  @spec misc() :: module()
  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  @spec scramble(chromosome :: chromosome(), bounds :: {array(), array()}, partial :: boolean()) ::
          chromosome()

  @doc """
    Scrambles the list of genes of a chromosome
  """
  def scramble(chromosome, bounds, partial \\ false)

  def scramble(%Chromosome{genes: genes} = chromosome, _bounds, partial) do
    new_genes =
      if partial do
        num_genes = Arrays.size(genes)
        {cut_point1, cut_point2} = misc().get_cut_points(num_genes)
        sliced_genes = Arrays.slice(genes, cut_point1..cut_point2)

        front = Arrays.slice(genes, 0..(cut_point1 - 1))
        middle = sliced_genes |> misc().shuffle() |> Arrays.new()
        back = Arrays.slice(genes, (cut_point2 + 1)..(num_genes - 1))

        front
        |> Arrays.concat(middle)
        |> Arrays.concat(back)
      else
        genes
        |> misc().shuffle()
        |> Arrays.new()
      end

    %Chromosome{chromosome | genes: new_genes}
  end

  @spec one_gene(chromosome :: chromosome(), bounds :: {array(), array()}) :: chromosome()

  @doc """
    Takes a chromosome, the genes' bounds and mutates one of the genes at random
  """
  def one_gene(%Chromosome{genes: genes} = chromosome, {upper, lower} = _bounds) do
    size = Arrays.size(genes)
    gene_index = misc().random(0..(size - 1))
    range = lower[gene_index]..upper[gene_index]
    mutated_gene = misc().random(range)

    new_genes =
      genes
      |> Arrays.replace(gene_index, mutated_gene)

    %Chromosome{chromosome | genes: new_genes}
  end

  @spec all_genes(chromosome :: chromosome(), bounds :: {array(), array()}) :: chromosome()

  @doc """
  Takes a chromosome, its bounds and mutates all of the genes
  """
  def all_genes(%Chromosome{genes: genes} = chromosome, {upper, lower} = _bounds) do
    size = Arrays.size(genes)

    new_genes =
      for(gene_index <- 0..(size - 1)) do
        range = lower[gene_index]..upper[gene_index]
        misc().random(range)
      end
      |> Arrays.new()

    %Chromosome{chromosome | genes: new_genes}
  end

  @spec flip(chromosome :: chromosome(), rate :: float()) :: chromosome()

  @doc """
    Flips the binary genes chromosome. Raises exception of non binary genes are present
  """
  def flip(chromosome, rate \\ 1.0)

  def flip(chromosome, rate) do
    flipped_genes =
      chromosome.genes
      |> Arrays.map(fn gene ->
        if !(gene in 0..1), do: raise("Cannot flip non binary gene")

        if misc().random() <= rate, do: Bitwise.bxor(gene, 1), else: gene
      end)

    %Chromosome{chromosome | genes: flipped_genes}
  end

  @doc """
    Performs gaussian mutation.
  """
  def gaussian(%Chromosome{genes: genes} = chromosome) do
    total_size = Arrays.size(genes)
    mean = Enum.sum(genes) / total_size

    variance =
      genes
      |> Arrays.map(fn gene -> (mean - gene) ** 2 end)
      |> Enum.sum()
      |> Kernel./(total_size)

    mutated_genes =
      genes
      |> Arrays.map(fn _ -> misc().random(mean, variance) end)

    %Chromosome{chromosome | genes: mutated_genes}
  end

  @doc """
    Performs swap mutation
  """
  def swap(%Chromosome{genes: genes} = chromosome) do
    num_genes = Arrays.size(genes)

    if num_genes < 2 do
      raise "Cannot apply swap mutation to chromosomes with less than 2 genes"
    end

    i = misc().random(0..(num_genes - 1))
    j = misc().random(0..(num_genes - 1))

    x = genes[i]
    y = genes[j]

    mutated_genes =
      genes
      |> Arrays.replace(i, y)
      |> Arrays.replace(j, x)

    %Chromosome{chromosome | genes: mutated_genes}
  end

  @doc """
    Performs invert mutation
  """
  def invert(%Chromosome{genes: genes} = chromosome) do
    mutated_genes =
      genes
      |> Enum.reverse()

    %Chromosome{chromosome | genes: mutated_genes}
  end
end
