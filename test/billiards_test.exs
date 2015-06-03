defmodule TestResource do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end
  
  def handle_call({:ping}, _from, state) do
    {:reply, :pong, state}
  end

  def handle_call({:do, fun}, _from, state) do
    {:reply, fun.(), state}
  end

  def handle_call({:crash}, _from, _state) do
    Process.exit self(), :normal
  end
end

defmodule Helper do
  def many_async(pool, count, call) do
    Enum.map 1..count, fn (_index) -> 
      Task.async fn -> Billiards.call(pool, call) end
    end   
  end

  def await_all(tasks) do
    Enum.map tasks, &Task.await(&1) 
  end
end

defmodule BilliardsTest do
  use ExUnit.Case
  import Helper

  setup do
    {:ok, pool} = Billiards.rack(resource: TestResource, workers: 4)
    {:ok, pool: pool}
  end

  test "executes more tasks than has resources", %{pool: pool} do
    many_async(pool, 30, {:ping})
    |> await_all
    |> Enum.each fn (value) ->
      assert value == :pong
    end
  end

  test "crash recovery", %{pool: pool} do
    starting_workers = Billiards.list_workers(pool)
    catch_exit Billiards.call pool, {:crash}
    final_workers = Billiards.list_workers(pool)
    assert starting_workers !== final_workers
    assert length(starting_workers) == length(final_workers)
  end
end