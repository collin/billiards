defmodule Billiards.Pool do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end
  
  def init([]) do
    {:ok, %{waiting: [], busy: [], workers_supervisor: nil}}
  end

  def handle_call({:init_workers, workers_supervisor}, _from, state) do
    state = Map.put state, :workers_supervisor, workers_supervisor
    {:reply, nil, state}
  end

  def handle_call({:list_workers}, _from, state) do
    {:reply, Billiards.WorkersSupervisor.list_workers(state.workers_supervisor), state}
  end

  def handle_call({:return_resource, resource}, _from, state=%{waiting: [waiting|tail]}) do
    state = Map.put state, :waiting, tail
    send waiting, {self(), :next_resource, resource}
    {:reply, :ok, state}
  end

  def handle_call({:return_resource, resource}, _from, state) do
    state = Map.put state, :busy, state.busy -- [resource]
    {:reply, :ok, state}
  end

  def handle_cast({:get_next_available_resource, from}, state) do
    all_workers = Billiards.WorkersSupervisor.list_workers(state.workers_supervisor)
    workers = all_workers -- [state.busy]
    resource = Enum.at(workers, 0)
    case resource do
      nil ->
        state = Map.put(state, :waiting, state.waiting ++ [from])
      _ ->
        state = Map.put state, :busy, state.busy ++ [resource]
        send from, {self(), :next_resource, resource}
    end
    {:noreply, state}
  end
end