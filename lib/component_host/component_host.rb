module ComponentHost
  def self.start(name, &block)
    logger = Log.get(self)

    host = Host.build

    host.instance_exec host, &block

    if Defaults.env_var_info?
      STDOUT.puts
      STDOUT.puts "Environment Variables"
      STDOUT.puts "  ENTITY_CACHE_SCOPE: #{ENV['ENTITY_CACHE_SCOPE'].inspect}"
      STDOUT.puts "  MESSAGE_STORE_SETTINGS_PATH: #{ENV['MESSAGE_STORE_SETTINGS_PATH'].inspect}"
      STDOUT.puts "  HANDLE_STRICT: #{ENV['HANDLE_STRICT'].inspect}"
      STDOUT.puts "  LOG_LEVEL: #{ENV['LOG_LEVEL'].inspect}"
      STDOUT.puts "  LOG_TAGS: #{ENV['LOG_TAGS'].inspect}"
      STDOUT.puts "  LOG_HEADER: #{ENV['LOG_HEADER'].inspect}"
      STDOUT.puts "  LOG_FORMATTERS: #{ENV['LOG_FORMATTERS'].inspect}"
      STDOUT.puts "  CONSOLE_DEVICE: #{ENV['CONSOLE_DEVICE'].inspect}"
      STDOUT.puts "  STARTUP_INFO: #{ENV['STARTUP_INFO'].inspect}"
      STDOUT.puts "  ENV_VAR_INFO: #{ENV['ENV_VAR_INFO'].inspect}"
    end

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

    def self.env_var_info?
      EnvVarInfo.get == 'on'
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

    module EnvVarInfo
      def self.get
        ENV.fetch(env_var, default)
      end

      def self.env_var
        'ENV_VAR_INFO'
      end

      def self.default
        'on'
      end
    end
  end
end
