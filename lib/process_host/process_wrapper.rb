class ProcessHost
  class ProcessWrapper
    attr_reader :process
    attr_reader :heartbeat
    attr_reader :exception_notifier

    def initialize process, heartbeat, exception_notifier
      @process = process
      @heartbeat = heartbeat
      @exception_notifier = exception_notifier
    end

    %i(connect prepare_socket receive_socket).each do |method_name|
      define_method method_name do |*args|
        value = nil

        heartbeat.update
        notify_exceptions do
          value = process.public_send method_name, *args
        end

        heartbeat.update
        value
      end
    end

    def respond_to? method_name
      process.respond_to? method_name
    end

    private

    def notify_exceptions
      return yield
    rescue => error
      exception_notifier.(process, error)
      raise error
    end
  end
end
