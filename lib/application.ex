defmodule Genetic.Application do
  use Application
  alias Utilities.Stats
  alias Utilities.Genealogy

  def start(_start_type, _start_args) do
    children = [
      {Stats, []},
      {Genealogy, []}
    ]

    opts = [strategy: :one_for_one, name: Genetic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
