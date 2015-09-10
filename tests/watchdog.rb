require "ftest/script"
require "process_host"
require "timeout"

class HungProcess
  def start io
    sleep 0.01 while true
  end
end

process_host = ProcessHost.build do |config|
  config.logger = logger
  config.watchdog_timeout = 0.25
end

error = nil
begin
  process_host.run do
    add "hung-process", HungProcess.new
  end
rescue ProcessHost::Watchdog::TimeoutError
  error = true
end

assert error
