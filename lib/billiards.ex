defmodule Billiards do
  @moduledoc """
  A dumb little resource pool.

  ### Create a Pool

      {:ok, dial_pool} = Billiards.rack(resource: Dialer, workers: 4)
  
  ### Billiards initializes worker processes with `start_link/0`.
  ### You call your pool like it were a single GenServer
      
      {:ok, phone_call_to_jenny } = Billiards.call dial_pool, {:dial, '867-5309'}

  Billiards uses a dumb strategy to pick resources from the pool. Right now, it just takes the
  first available resource.

  If all resources are busy, the calling process will block until a resource is available 
  to serve it.
  """
  @doc """
  A terribly cute method.

      {:ok, pool} = Billiards.rack(genserver_resource, workers: 4)
  """
  def rack(options) do
    options = Enum.into options, %Billiards.Options{}
    Billiards.Supervisor.start_link(options)
  end

  @doc """
  Returns a list of process ids. These are the raw workers.

      Billiards.list_workers(pool)       
      [#PID<0.157.0>, #PID<0.156.0>, #PID<0.155.0>, #PID<0.154.0>]
  """
  def list_workers(pid) do
    GenServer.call(pid, {:list_workers})
  end

  @doc """
  Fetches the next available resource and passes the call along to it.

    Billiards.call(pool, argument)

  translates into:

    GenServer.call(worker, argument)

  TODO: Maybe this should be implemented with GenEvent to avoid leaks, etc.
  """
  def call(pid, tuple) do
    GenServer.cast(pid, {:get_next_available_resource, self()})
    {result, resource} = receive do
      {_from, :next_resource, resource} -> {GenServer.call(resource, tuple), resource}
    end
    GenServer.call(pid, {:return_resource, resource})
    result
  end
end