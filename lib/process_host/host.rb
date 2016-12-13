module ProcessHost
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

    def register(process_class, process_name=nil)
      logger.trace { "Registering process (ProcessClass: #{process_class}, Name: #{process_name.inspect})" }

      process_name ||= process_class.process_name

      if registered_process = processes[process_name]
        error_message = "Process with specified name is already registered (ProcessClass: #{process_class}, Name: #{process_name.inspect}, RegisteredProcessClass: #{registered_process.name})"

        logger.error error_message

        raise NameConflictError, error_message
      else
        processes[process_name] = process_class
      end

      logger.debug { "Process registered (ProcessClass: #{process_class}, Name: #{process_name.inspect})" }

      process_name
    end

    def record_error(&block)
      record_errors_observer.record_error_proc = block
    end

    def start(&block)
      started_processes = []

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

        start_processes do |process|
          started_processes << process
        end

        block.(supervisor) if block
      end

      started_processes
    end

    def start_processes(&block)
      processes.each_value do |process_class|
        process = process_class.build

        process.start

        block.(process) if block
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

    def processes
      @processes ||= {}
    end

    NameConflictError = Class.new StandardError

    module Assertions
      def registered?(&block)
        return processes.any? if block.nil?

        processes.any? do |name, process_class|
          block.(process_class, name)
        end
      end
    end
  end
end
