module ComponentHost
  def self.start(name, &block)
    logger = Log.get(self)

    host = Host.build

    host.instance_exec host, &block

    STDOUT.puts
    STDOUT.puts "Host: #{name}"
    logger.info(tags: [:component_host, :start, :lifecycle]) { "Starting host: #{name} (Process ID: #{::Process.pid})" }
    STDOUT.puts

    host.start do
      STDOUT.puts
      STDOUT.puts "Host running: #{name}"
      STDOUT.puts "Process ID: #{::Process.pid}"
      STDOUT.puts

      logger.info(tags: [:component_host, :start, :lifecycle]) { "Started host: #{name} (Process ID: #{::Process.pid})" }
    end
  end
end
