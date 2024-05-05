defmodule Selection do
  @moduledoc """
     The Crossover module contains some of the most commonly used selection strategies for genetic algorithms
  """

  require Integer

  @type chromosome() :: Chromosome.t()
  @type population() :: list(Chromosome.t())
  @type pair() :: {chromosome(), chromosome()}
  @type optimization() :: :max | :min

  @spec misc() :: module()

  @doc """
    Returns the Misc module
  """
  def misc, do: Application.get_env(:genetic, :misc)

  @spec elitism(
          population :: population(),
          population_size :: integer(),
          selection_rate :: float()
        ) ::
          list(chromosome())
  @doc """
    Takes a population sorted by fitness value and forms pairs using contiguous chromosome
  """
  def elitism(population, population_size, selection_rate) do
    mating_pool_size = calculate_mating_pool_size(population_size, selection_rate)

    population
    |> Enum.take(mating_pool_size)
  end

  @spec random(
          population :: population(),
          population_size :: integer(),
          selection_rate :: float()
        ) ::
          list(chromosome())
  @doc """
  Takes a population and chooses k random number of chromosomes at random
  """
  def random(population, population_size, selection_rate) do
    mating_pool_size = calculate_mating_pool_size(population_size, selection_rate)

    population
    |> misc().take_random(mating_pool_size)
  end

  @spec roulette(
          population :: population(),
          population_size :: integer(),
          selection_rate :: float(),
          fitness_factor :: float()
        ) :: list(chromosome())
  @doc """
    Takes a population, perform Roulette Selection and forms pairs using the chromosome's normalized fitnesses to calculate probabilties
  """
  def roulette(population, population_size, selection_rate, fitness_factor \\ 1.0) do
    probabilities = calculate_probabilities(population, fitness_factor)
    mating_pool_size = calculate_mating_pool_size(population_size, selection_rate)

    population
    |> Enum.zip(probabilities)
    |> go_to_casino([], 0, mating_pool_size)
    |> misc().shuffle()
  end

  @spec rank(
          population :: population(),
          population_size :: integer(),
          selection_rate :: float(),
          selection_pressure :: float()
        ) :: list(chromosome())
  @doc """
  TODO: Revised this algorithm
  """
  def rank(population, population_size, selection_rate, selection_pressure \\ 1.5) do
    probabilities = calculate_ranked_probabilities(population_size, selection_pressure)
    mating_pool_size = calculate_mating_pool_size(population_size, selection_rate)

    population
    |> Enum.zip(probabilities)
    |> go_to_casino([], 0, mating_pool_size)
    |> misc().shuffle()
  end

  @spec stochastic_universal_sampling(
          population :: population(),
          population_size :: integer(),
          selection_rate :: float(),
          fitness_factor :: float()
        ) :: list(chromosome())
  @doc """
    Stochastic Universal Sampling
  """
  def stochastic_universal_sampling(
        population,
        population_size,
        selection_rate,
        fitness_factor \\ 1.0
      ) do
    mating_pool_size = calculate_mating_pool_size(population_size, selection_rate)

    {fitnesses_sum, _, cummulative_fitnesses} =
      transform_fitnesses(population, fitness_factor)

    step_size = div(round(fitnesses_sum), population_size)
    start = misc().random(0..step_size)

    pointers =
      0..(mating_pool_size - 1)
      |> Enum.map(fn index ->
        start + index * step_size
      end)

    population
    |> Enum.zip(cummulative_fitnesses)
    |> do_sus_select(pointers, [])
  end

  @spec tournament(
          population :: population(),
          population_size :: integer(),
          selection_rate :: float(),
          optimization :: optimization()
        ) :: list(chromosome())
  @doc """
    Takes a population of chromosome, performs Tournament Selection and returns a list of pairs
  """
  def tournament(
        population,
        population_size,
        selection_rate,
        optimization,
        num_participants \\ 2,
        allow_duplicates? \\ true
      ) do
    optimize_by_function = if optimization == :max, do: &Enum.max_by/2, else: &Enum.min_by/2

    mating_pool_size = calculate_mating_pool_size(population_size, selection_rate)

    if allow_duplicates? do
      tournament_duplicates(population, mating_pool_size, num_participants, optimize_by_function)
    else
      pool = MapSet.new()

      tournament_no_duplicates(
        population,
        num_participants,
        0,
        mating_pool_size,
        pool,
        optimize_by_function
      )
    end
  end

  defp tournament_duplicates(population, mating_pool_size, num_participants, optimize_by_function) do
    0..(mating_pool_size - 1)
    |> Enum.map(fn _ ->
      population
      |> misc().take_random(num_participants)
      |> optimize_by_function.(& &1.fitness)
    end)
  end

  defp tournament_no_duplicates(
         _,
         _,
         current_pool_size,
         max_pool_size,
         pool,
         _
       )
       when current_pool_size == max_pool_size,
       do: MapSet.to_list(pool)

  defp tournament_no_duplicates(
         population,
         num_participants,
         current_pool_size,
         max_pool_size,
         pool,
         optimize_by_function
       ) do
    chosen =
      population
      |> misc().take_random(num_participants)
      |> optimize_by_function.(& &1.fitness)

    new_pool = MapSet.put(pool, chosen)

    tournament_no_duplicates(
      population,
      num_participants,
      current_pool_size + 1,
      max_pool_size,
      new_pool,
      optimize_by_function
    )
  end

  defp go_to_casino(_, pool, num_spins, quota) when num_spins == quota, do: pool

  defp go_to_casino(population_probabilities, pool, num_spins, quota) do
    {chromosome, _} = spin_roulette(population_probabilities)
    go_to_casino(population_probabilities, [chromosome | pool], num_spins + 1, quota)
  end

  defp spin_roulette(population_probabilities) do
    spin = misc().random()

    population_probabilities
    |> Enum.find(fn {_, probability} ->
      spin < probability
    end)
  end

  defp calculate_probabilities(population, fitness_factor) do
    {fitnesses_sum, fitnesses, _} = transform_fitnesses(population, fitness_factor)

    [_ | probabilities] =
      fitnesses
      |> Enum.reduce([], fn fitness, probs ->
        prev_prob = if Enum.empty?(probs), do: 0, else: hd(probs)
        new_prob = prev_prob + fitness / fitnesses_sum
        [new_prob | probs]
      end)

    [1.0 | probabilities]
    |> Enum.reverse()
  end

  defp calculate_ranked_probabilities(population_size, selection_pressure) do
    for i <- 0..(population_size - 1) do
      2 - selection_pressure + 2 * (selection_pressure - 1) * i / population_size
    end
  end

  # Returns the list of normalized fit vals, the list of cummulative fit vals and the sum of all fit vals
  defp transform_fitnesses(population, fitness_factor) do
    {min_fitness, max_fitness} = misc().minmax_fitness(population)
    max_fitness = max_fitness + 1
    base = max_fitness + fitness_factor * (max_fitness - min_fitness)

    {normalized_fitnesses, cummulative_fitnesses} =
      population
      |> Enum.reduce({[], []}, fn chromosome, {norm_fits, cumm_fits} ->
        prev_sum = if Enum.empty?(cumm_fits), do: 0, else: hd(cumm_fits)
        new_fit = base - chromosome.fitness
        new_sum = prev_sum + new_fit
        {[new_fit | norm_fits], [new_sum | cumm_fits]}
      end)

    {
      hd(cummulative_fitnesses),
      Enum.reverse(normalized_fitnesses),
      Enum.reverse(cummulative_fitnesses)
    }
  end

  defp do_sus_select(_, [], selected), do: selected

  defp do_sus_select([{_, cumm_fit} | _], [pointer | _], selected) when cumm_fit >= pointer do
    selected
  end

  defp do_sus_select([{chromosome, _} | pop_cumm_fit], [_ | pointers], selected) do
    do_sus_select(pop_cumm_fit, pointers, [chromosome | selected])
  end

  defp calculate_mating_pool_size(population_size, selection_rate) do
    mating_pool_size = floor(population_size * selection_rate)
    if Integer.is_odd(mating_pool_size), do: mating_pool_size + 1, else: mating_pool_size
  end
end
