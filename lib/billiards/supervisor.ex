defmodule Billiards.Supervisor do
  use Supervisor

  def start_link(config) do
    result = {:ok, supervisor} = Supervisor.start_link __MODULE__, []
    start_workers(supervisor, config)
  end
  
  def start_workers(supervisor, config) do
    {:ok, pool} = Supervisor.start_child(supervisor, worker(Billiards.Pool, []))
    config = Map.put config, :pool, pool
    Supervisor.start_child(supervisor, supervisor(Billiards.WorkersSupervisor, [config]))
    {:ok, pool}
  end

  def init([]) do
    supervise [], strategy: :one_for_one
  end
end