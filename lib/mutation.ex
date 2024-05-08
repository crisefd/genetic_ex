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

  @spec scramble(chromosome :: chromosome(), partial :: boolean()) :: chromosome()

  @doc """
    Scrambles the list of genes of a chromosome
  """
  def scramble(chromosome, partial \\ false)

  def scramble(chromosome, partial) do
    new_genes =
      if partial do
        num_genes = Arrays.size(chromosome.genes)
        {cut_point1, cut_point2} = misc().get_cut_points(num_genes)
        sliced_genes = Arrays.slice(chromosome.genes, cut_point1..cut_point2)

        front = Arrays.slice(chromosome.genes, 0..(cut_point1 - 1))
        middle = sliced_genes |> misc().shuffle() |> Arrays.new()
        back = Arrays.slice(chromosome.genes, (cut_point2 + 1)..(num_genes - 1))

        front
        |> Arrays.concat(middle)
        |> Arrays.concat(back)
      else
        chromosome.genes
        |> misc().shuffle()
        |> Arrays.new()
      end

    %Chromosome{chromosome | genes: new_genes}
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

      %Chromosome{chromosome | genes: new_genes}
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

    %Chromosome{chromosome | genes: new_genes}
  end

  @spec flip(chromosome :: chromosome()) :: chromosome()

  @doc """
    Flips the binary genes chromosome. Raises exception of non binary genes are present
  """
  def flip(chromosome, rate \\ 1.0) do
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
