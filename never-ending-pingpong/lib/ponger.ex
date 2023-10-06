defmodule Pingpong.Ponger do
  def pong do
    receive do
      {:smack, pinger_pid} ->
        IO.inspect("Ponger:  Haiii!!")
        Process.sleep(1000)
        send(pinger_pid, {:smack, self()})
      _ -> IO.inspect("invalid")
    end
    pong()
  end
end


