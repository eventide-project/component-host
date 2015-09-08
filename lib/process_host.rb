require "fiber"

module ProcessHost
  autoload :Builder, "process_host/builder"
  autoload :Host, "process_host/host"
  autoload :Iteration, "process_host/iteration"
  autoload :IOWrapper, "process_host/io_wrapper"
  autoload :Process, "process_host/process"
  autoload :Logging, "process_host/logging"
  autoload :Runner, "process_host/runner"
  autoload :Watchdog, "process_host/watchdog"

  def self.build &block
    Builder.(block)
  end
end
