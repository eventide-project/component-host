module ComponentHost
  def self.start(name, &block)
    logger = Log.get(self)

    host = Host.build

    host.instance_exec host, &block

    if Defaults.startup_info?
      STDOUT.puts
      STDOUT.puts "Host: #{name}"
    end
    logger.info(tags: [:component_host, :start, :lifecycle]) { "Starting host: #{name} (Process ID: #{::Process.pid})" }

    if Defaults.startup_info?
      STDOUT.puts
    end

    host.start do
      if Defaults.startup_info?
        STDOUT.puts
        STDOUT.puts "Host running: #{name}"
        STDOUT.puts "Process ID: #{::Process.pid}"
        STDOUT.puts
      end

      logger.info(tags: [:component_host, :start, :lifecycle]) { "Started host: #{name} (Process ID: #{::Process.pid})" }
    end
  end

  module Defaults
    def self.startup_info?
      StartupInfo.get == 'on'
    end

    module StartupInfo
      def self.get
        ENV.fetch(env_var, default)
      end

      def self.env_var
        'STARTUP_INFO'
      end

      def self.default
        'on'
      end
    end
  end
end
