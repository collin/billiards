defmodule Billiards.WorkersSupervisor do
  use Supervisor

  def start_link(config) do
    result = {:ok, supervisor} = Supervisor.start_link(__MODULE__, config)
    start_workers(supervisor, config)
    result
  end

  def start_workers(supervisor, config) do
    workers = Enum.map(1..config.workers, fn (id) ->
      {:ok, worker} = Supervisor.start_child(supervisor, worker(config.resource, [], id: id))
    end)
    GenServer.call config.pool, {:init_workers, supervisor}
    workers
  end

  def list_workers(supervisor) do
    Enum.map Supervisor.which_children(supervisor), fn ({_, worker, _, _}) -> worker end
  end

  def init(config) do
    supervise [], strategy: :one_for_one
  end
end