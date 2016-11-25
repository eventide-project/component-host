module ProcessHost
  class Host
    include Log::Dependency

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
