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

process_host = ProcessHost.build do |config|
  config.logger = logger
  config.heartbeat_threshold_ms = 50
end
process_host.add HungProcess.new

timer 0.1 do
  process_host.run
end

error = nil
begin
  Process.kill "USR1", Process.pid
rescue ProcessHost::Heartbeat::Error
  error = true
end

assert error
