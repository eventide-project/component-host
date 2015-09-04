class ProcessHost
  class ProcessWrapper
    include Observable

    DELEGATE_METHODS = %i(connect prepare_socket receive_socket)

    attr_reader :name
    attr_reader :process
    alias_method :delegate, :process

    def initialize name, process
      @name = name
      @process = process
    end

    DELEGATE_METHODS.each do |method_name|
      define_method method_name do |*args|
        invoke method_name, args
      end
    end

    def invoke method_name, args
      changed
      notify_observers :dispatch, self, method_name
      process.public_send method_name, *args
    rescue => error
      changed
      notify_observers :error, self, error
      raise error
    end

    def respond_to? method_name
      if DELEGATE_METHODS.include? method_name
        process.respond_to? method_name
      else
        super
      end
    end
  end
end
