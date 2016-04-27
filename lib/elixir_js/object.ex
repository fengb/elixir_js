defmodule ElixirJs.Object do
  use GenServer

  def create(proto \\ nil) do
    GenServer.start_link(ElixirJs.Object, proto)
  end

  def init(nil), do: {:ok, %{}}
  def init(proto) when is_pid(proto) do
    state = %{ __proto__: proto }
    {:ok, state}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, lookup_value(state, key), state}
  end

  def handle_call({:set, key, value}, _from, state) do
    {:reply, value, Map.put(state, key, value) }
  end

  def handle_call({:delete, key}, _from, state) do
    {:reply, nil, Map.delete(state, key)}
  end

  defp lookup_value(key, state) do
    cond do
      Map.has_key?(state, key) ->
        Map.get(state, key)
      Map.has_key?(state, :__proto__) ->
        proto = Map.get(state, :__proto__)
        GenServer.call(proto, {:get, key})
      true ->
        nil
    end
  end
end
