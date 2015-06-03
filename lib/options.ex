defmodule Billiards.Options do
  defstruct [:workers, :pool, :resource]
end

defimpl Collectable, for: Billiards.Options do
  def into(original) do
    {original, fn
      map, {:cont, {k, v}} -> :maps.put(k, v, map)
      map, :done -> map
      _, :halt -> :ok
    end}
  end
end