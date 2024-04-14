optimal_fitness = 100

genotype = fn ->
  Arrays.new(for _ <- 1..optimal_fitness, do: Enum.random(0..1))
end

fitness_function = fn chromosome ->
  chromosome
  |> Arrays.reduce(0, fn val, acc -> val + acc  end)
end

Genetic.execute(genotype, fitness_function, optimal_fitness) |> IO.inspect()
