module ProcessHost
  class Host
    include ::Log::Dependency

    attr_writer :record_error_proc

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
      self.record_error_proc = block
    end

    def start(&block)
      started_processes = []

      Actor::Supervisor.start do |supervisor|
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

        processes.each_value do |process_class|
          process = process_class.build

          started_processes << process

          process.start
        end

        block.(supervisor) if block
      end

      started_processes

    rescue => error
      logger.fatal "Error raised; exiting process (ErrorClass: #{error.class.name}, Message: #{error.message.inspect})"
      record_error_proc.(error)
      raise error
    end

    def processes
      @processes ||= {}
    end

    def record_error_proc
      @record_error_proc ||= proc { }
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
