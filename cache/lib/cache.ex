defmodule Cache do
  use GenServer

  @name RS

  ## client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: RS])
  end

  def write(key, value) do
    GenServer.call(@name, {:write, {key, value}})
  end

  def read(key) do
    GenServer.call(@name, {:read, key})
  end

  def delete(key) do
    GenServer.call(@name, {:delete, key})
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def exist?(key) do
    GenServer.call(@name, {:exists, key})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## server callbacks
  def init(:ok) do
    {:ok, %{}}    
  end

  def handle_call({:exists, key}, _from, cache) do
    {:reply, Map.has_key?(cache, key), cache}
  end

  def handle_call({:read, key}, _from, cache) do
    case Map.has_key?(cache, key) do
       true -> {:reply, {:success, Map.get(cache, key)}, cache}
       false -> {:reply, :keynotfound, cache}
    end
  end

  def handle_call({:delete, key}, _from, cache) do
    {:reply, :success, Map.delete(cache, key)}
  end

  def handle_call({:write, {key, value}}, _from, cache) do
    {:reply, :success, Map.put(cache, key, value)}
  end


  def handle_cast(:clear, _cache) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, cache) do
    {:stop, :normal, cache}
  end   

  def handle_info(msg, cache) do
    IO.puts "received #{inspect msg}"
    {:noreply, cache}
  end

  def terminate(reason, cache) do
    IO.inspect "server terminated because of #{inspect reason}, cache below"
    IO.inspect cache
    :ok
  end
   
  ## helper functions

end
