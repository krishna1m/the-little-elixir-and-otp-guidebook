defmodule Pingpong.Pinger do
  def ping do
    receive do
      {:start, ponger_pid} ->
        IO.inspect("Pinger serving.....")
        Process.sleep(1000)
        IO.inspect("Pinger:  Haiyaa!!")
        Process.sleep(1000)
        send(ponger_pid, {:smack, self()})
      {:smack, ponger_pid} ->
        IO.inspect("Pinger:  Haiyaa!!")
        Process.sleep(1000)
        send(ponger_pid, {:smack, self()})
      _ -> IO.inspect("invalid")
    end
    ping()
  end
end

