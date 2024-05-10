defmodule Utilities.Genealogy do
  use GenServer

  @me __MODULE__

  # Server side

  def init(_) do
    {:ok, Graph.new()}
  end

  def handle_cast({:add_chromosomes, chromosomes}, genealogy) do
    {:noreply, Graph.add_vertices(genealogy, chromosomes)}
  end

  def handle_cast({:add_chromosomes, parent, child}, genealogy) do
    {:noreply, Graph.add_edge(genealogy, parent, child)}
  end

  def handle_cast({:add_chromosomes, parent1, parent2, child}, genealogy) do
    new_genealogy =
      genealogy
      |> Graph.add_edge(parent1, child)
      |> Graph.add_edge(parent2, child)

    {:noreply, new_genealogy}
  end

  def handle_call(:get_tree, _from, genealogy) do
    {:reply, genealogy, genealogy}
  end

  # Client side

  def start_link(state) do
    GenServer.start_link(@me, state, name: @me)
  end

  def add_chromosomes(chromosomes) do
    GenServer.cast(@me, {:add_chromosomes, chromosomes})
  end

  def add_chromosomes(parent, child) do
    GenServer.cast(@me, {:add_chromosomes, parent, child})
  end

  def add_chromosomes(parent1, parent2, child) do
    GenServer.cast(@me, {:add_chromosomes, parent1, parent2, child})
  end

  def get_tree do
    GenServer.call(@me, :get_tree)
  end
end
