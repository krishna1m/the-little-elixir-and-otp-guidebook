defmodule ThySupervisor do
  use GenServer

  ## API
  def start_link(child_spec_list \\ []) do
    GenServer.start_link(__MODULE__, [child_spec_list])
  end

  def start_child(supervisor, child_spec) do
    GenServer.call(supervisor, {:start_child, child_spec})
  end

  def terminate_child(supervisor, pid) when is_pid(pid) do
    GenServer.call(supervisor, {:terminate_child, pid})
  end

  def restart_child(supervisor, pid) when is_pid(pid) do
    GenServer.call(supervisor, {:restart_child, pid})
  end

  def count_children(supervisor) do
    GenServer.call(supervisor, :count_children)
  end

  def which_children(supervisor) do
    GenServer.call(supervisor, :which_children)
  end

  def stop(supervisor) do
    GenServer.cast(supervisor, :stop)
  end


  ## callback functions
  def init([child_spec_list]) do
    Process.flag(:trap_exit, true)
    state = child_spec_list
            |> start_children
            |> Enum.into(Map.new)
    {:ok, state}
  end

  def handle_call({:start_child, child_spec}, _from, state) do
    case start_child(child_spec) do
      {:ok, pid} ->
        {:reply, {:ok, pid}, state |> Map.put(pid, child_spec)}
      :error ->
        {:reply, {:error, "error starting child"}, state}
    end
  end

  def handle_call({:terminate_child, pid}, _from, state) do
    case terminate_child(pid) do
      :ok ->
        {:reply, :ok, Map.delete(state, pid)}
      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call({:restart_child, old_pid}, _from, state) do
    case Map.get(state, old_pid) do
      {:ok, child_spec} ->
        case restart_child_(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
            new_state = state
                        |> Map.delete(old_pid)
                        |> Map.put(pid, child_spec)
            {:reply, {:ok, pid}, new_state}
          :error ->
            {:reply, :error, state}
        end
      _ ->
        {:reply, :ok, state}
    end
  end

  def handle_call(:count_children, _from, state) do
    {:reply, Enum.count(state), state}
  end

  def handle_call(:which_children, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_info({:EXIT, from, :killed}, state) do
    {:noreply, state |> Map.delete(from)}
  end

  def handle_info({:EXIT, from, :normal}, state) do
    {:noreply, state |> Map.delete(from)}
  end

  def handle_info({:EXIT, old_pid, _reason}, state) do
    case Map.has_key?(state, old_pid) do
      true ->
        child_spec = Map.get(state, old_pid)
        case restart_child_(old_pid, child_spec) do
          {:ok, {pid, child_spec}} ->
            new_state = state
                        |> Map.delete(old_pid)
                        |> Map.put(pid, child_spec)
            {:noreply, new_state}
          _ ->
            {:noreply, state}
        end
      false ->
        {:noreply, state}
    end
  end

  def terminate(_reason, state) do
    terminate_children(state)
    :ok
  end

  ## private functions
  def start_child({mod, fun, args}) do
    case apply(mod, fun, args) do
      pid when is_pid(pid) ->
        Process.link(pid)
        {:ok, pid}
      _ ->
        :error
    end
  end

  defp start_children([]), do: []
  defp start_children([child_spec | rest]) do
    case start_child(child_spec) do
      {:ok, pid} ->
        [{pid, child_spec} | start_children(rest)]
      :error ->
        :error
    end
  end

  defp restart_child_(pid, child_spec) when is_pid(pid) do
    case terminate_child(pid) do
      :ok ->
        case start_child(child_spec) do
          {:ok, new_pid} ->
            {:ok, {new_pid, child_spec}}
          :error ->
            :error
        end
      _ ->
        :error
    end
  end

  defp terminate_child(pid) do
    Process.exit(pid, :kill)
    :ok
  end

  defp terminate_children([]), do: :ok
  defp terminate_children(child_specs) do
    child_specs
    |> Enum.each(fn {pid, _} -> terminate_child(pid) end)
  end

end
