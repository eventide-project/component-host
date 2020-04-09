module ComponentHost
  class Host
    include Dependency
    include Log::Dependency

    dependency :signal, Signal
    dependency :send, Actor::Messaging::Send

    def self.build
      instance = new
      Signal.configure instance
      instance.send = Actor::Messaging::Send
      instance
    end

    def register(initiator, name=nil, &block)
      initiator ||= proc { yield }

      logger.trace(tag: :component_host) { "Registering component (Component Initiator: #{initiator}, Name: #{name || '(none)'})" }

      component = Component.new initiator, name

      components << component

      logger.debug(tag: :component_host) { "Registered component (Component Initiator: #{initiator}, Name: #{name || '(none)'})" }

      component
    end

    def record_error(&block)
      record_errors_observer.record_error_proc = block
    end

    def start(&probe)
      started_components = []

      Actor::Supervisor.start do |supervisor|
        supervisor.add_observer record_errors_observer

        supervisor.add_observer log_observer

        signal.trap 'TSTP' do
          message = Actor::Messages::Suspend

          send.(message, supervisor.address)

          logger.info(tags: [:*, :signal]) { "Handled TSTP signal (Message Name: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        signal.trap 'CONT' do
          message = Actor::Messages::Resume

          send.(message, supervisor.address)

          logger.info(tags: [:*, :signal]) { "Handled CONT signal (Message Name: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        signal.trap 'INT' do
          message = Actor::Messages::Shutdown

          send.(message, supervisor.address)

          logger.info(tags: [:*, :signal]) { "Handled INT signal (Message Name: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        signal.trap 'TERM' do
          message = Actor::Messages::Shutdown

          send.(message, supervisor.address)

          logger.info(tags: [:*, :signal]) { "Handled TERM signal (Message Name: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        start_components do |component|
          started_components << component
        end

        probe.(supervisor) if probe
      end

      started_components
    end

    def start_components(&block)
      components.each do |component|
        STDOUT.puts "  Component: #{component.initiator} (Name: #{component.name || '(none)'})"

        logger.trace(tags: [:component_host, :start]) { "Starting component: #{component.initiator} (Name: #{component.name || '(none)'})" }

        component.start

        logger.info(tags: [:component_host, :start]) { "Started component: #{component.initiator} (Name: #{component.name || '(none)'})" }

        block.(component) if block
      end

    rescue => error
      record_errors_observer.(error)
      logger.fatal(tags: [:*, :component_host, :start]) { "#{error.message} (Error: #{error.class})" }
      raise error
    end

    def record_errors_observer
      @record_errors_observer ||= SupervisorObservers::RecordErrors.new
    end

    def log_observer
      @log_observer ||= SupervisorObservers::Log.new
    end

    def components
      @components ||= []
    end

    def abort
      raise StopIteration
    end

    def registered?(&block)
      block ||= proc { true }

      components.any? do |component|
        block.(component.initiator, component.name)
      end
    end

    Component = Struct.new :initiator, :name do
      def start
        initiator.()
      end
    end
  end
end
