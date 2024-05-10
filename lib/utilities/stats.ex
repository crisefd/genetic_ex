defmodule Utilities.Stats do
  use GenServer

  @me __MODULE__
  @table_name :statistics

  # Server side

  def init(state) do
    :ets.new(:statistics, [:set, :public, :named_table])
    {:ok, state}
  end

  def start_link(state) do
    GenServer.start_link(@me, state, name: @me)
  end

  def handle_info({:record, payload}, state) do
    [population: population, generation: generation, stats_functions: stats_functions] = payload
    stats_map = calculate(stats_functions, population)
    insert(generation, stats_map)
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # Client side

  def record(data) do
    send(@me, {:record, data})
  end

  # ETS Wrapper
  def insert(generation, stats) do
    :ets.insert(@table_name, {generation, stats})
  end

  def lookup(generation) do
    try do
      :ets.lookup(@table_name, generation)
      |> hd()
    rescue
      ArgumentError ->
        IO.puts("No stats found for generation #{generation}")
        %{}
    end
  end

  defp calculate(stats, population) do
    stats
    |> Enum.reduce(%{}, fn {key, function}, acc ->
      Map.put(acc, key, function.(population))
    end)
  end
end