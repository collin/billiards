# Billiards is a resource pool.
# 
# 1: Create a Pool
#   {:ok, dial_pool} = Billiards.rack(Dialer, workers: 4)
# 2: Billiards initializes worker processes (GenServer)
# 3: You call your pool like it were a single GenServer
#   {:ok, phone_call_to_jenny } = Billiards.call dial_pool, {:dial, '867-5309'}
# 
#
# Downsides?
#
# 1: I don't know OTP
# 2: No :cast or :info
# 3: The pool is NOT really a GenServer.

# Maybe we can expose hooks later so you
# can get hooks into the actual servers.
# 
# Maybe this should be a specialized version of GenServer?


defmodule Billiards do
  @doc """
  A terribly cute method.

      {:ok, pool} = Billiards.rack(genserver_resource, workers: 4)
  """
  def rack(options) do
    options = Enum.into options, %Billiards.Options{}
    Billiards.Supervisor.start_link(options)
  end

  def list_workers(pid) do
    GenServer.call(pid, {:list_workers})
  end

  def call(pid, tuple) do
    GenServer.cast(pid, {:get_next_available_resource, self()})
    {result, resource} = receive do
      {_from, :next_resource, resource} -> {GenServer.call(resource, tuple), resource}
    end
    GenServer.call(pid, {:return_resource, resource})
    result
  end
end