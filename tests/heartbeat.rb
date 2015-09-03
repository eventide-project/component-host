require "ftest/script"
require "process_host"
require "timeout"

class HungProcess
  def connect
    sleep 0.1 while true
  end
end

def timer duration, &block
  Timeout.timeout duration, &block
rescue Timeout::Error
end

process_host = ProcessHost.new logger, heartbeat: 0.05
process_host.add HungProcess.new

timer 0.1 do
  process_host.run
end

error = nil
begin
  Process.kill "USR1", Process.pid
rescue ProcessHost::HeartbeatError
  error = true
end

assert error
