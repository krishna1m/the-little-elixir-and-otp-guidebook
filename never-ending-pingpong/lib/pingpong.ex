defmodule Pingpong do
  def start_play do
    pinger_pid = spawn(Pingpong.Pinger, :ping, [])
    ponger_pid = spawn(Pingpong.Ponger, :pong, [])
    send(pinger_pid, {:start, ponger_pid})
  end
end
