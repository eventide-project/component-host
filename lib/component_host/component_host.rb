module ComponentHost
  def self.start(name, &block)
    logger = Log.get(self)

    host = Host.build

    host.instance_exec host, &block

    if Defaults.env_var_info?
      STDOUT.puts
      STDOUT.puts "Environment Variables:"
      STDOUT.puts "  ENTITY_CACHE_SCOPE: #{ENV['ENTITY_CACHE_SCOPE'] || '(not set)'}"
      STDOUT.puts "  MESSAGE_STORE_SETTINGS_PATH: #{ENV['MESSAGE_STORE_SETTINGS_PATH'] || '(not set)'}"
      STDOUT.puts "  HANDLE_STRICT: #{ENV['HANDLE_STRICT'] || '(not set)'}"
      STDOUT.puts "  LOG_LEVEL: #{ENV['LOG_LEVEL'] || '(not set)'}"
      STDOUT.puts "  LOG_TAGS: #{ENV['LOG_TAGS'] || '(not set)'}"
      STDOUT.puts "  LOG_HEADER: #{ENV['LOG_HEADER'] || '(not set)'}"
      STDOUT.puts "  LOG_FORMATTERS: #{ENV['LOG_FORMATTERS'] || '(not set)'}"
      STDOUT.puts "  CONSOLE_DEVICE: #{ENV['CONSOLE_DEVICE'] || '(not set)'}"
      STDOUT.puts "  STARTUP_INFO: #{ENV['STARTUP_INFO'] || '(not set)'}"
      STDOUT.puts "  ENV_VAR_INFO: #{ENV['ENV_VAR_INFO'] || '(not set)'}"
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
