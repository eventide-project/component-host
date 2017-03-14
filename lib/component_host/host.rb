module ComponentHost
  class Host
    include ::Log::Dependency

    dependency :signal, Signal
    dependency :send, Actor::Messaging::Send

    def self.build
      instance = new
      Signal.configure instance
      instance.send = Actor::Messaging::Send
      instance
    end

    def register(start_proc, name=nil, &block)
      start_proc ||= proc { yield }

      logger.trace { "Registering component (StartProcedure: #{start_proc}, Name: #{name || '(none)'})" }

      component = Component.new start_proc, name

      components << component

      logger.debug { "Component registered (StartProcedure: #{start_proc}, Name: #{name || '(none)'})" }

      component
    end

    def record_error(&block)
      record_errors_observer.record_error_proc = block
    end

    def start(&block)
      started_components = []

      Actor::Supervisor.start do |supervisor|
        supervisor.add_observer record_errors_observer

        supervisor.add_observer log_observer

        signal.trap 'TSTP' do
          message = Actor::Messages::Suspend

          send.(message, supervisor.address)

          logger.info { "Handled TSTP signal (MessageName: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        signal.trap 'CONT' do
          message = Actor::Messages::Resume

          send.(message, supervisor.address)

          logger.info { "Handled CONT signal (MessageName: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        signal.trap 'INT' do
          message = Actor::Messages::Shutdown

          send.(message, supervisor.address)

          logger.info { "Handled INT signal (MessageName: #{message.message_name}, SupervisorAddress: #{supervisor.address.id})" }
        end

        start_components do |component|
          started_components << component
        end

        block.(supervisor) if block
      end

      started_components
    end

    def start_components(&block)
      components.each do |component|
        component.start

        block.(component) if block
      end

    rescue => error
      record_errors_observer.(error)
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

    Component = Struct.new :start_proc, :name do
      def start
        start_proc.()
      end
    end

    module Assertions
      def registered?(&block)
        block ||= proc { true }

        components.any? do |component|
          block.(component.start_proc, component.name)
        end
      end
    end
  end
end
