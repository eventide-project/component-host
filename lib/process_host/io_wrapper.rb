module ProcessHost
  class IOWrapper
    autoload :DeferredAction, "process_host/io_wrapper/deferred_action"

    attr_reader :host_fiber
    attr_reader :pending_action
    attr_reader :socket

    def initialize host_fiber
      @host_fiber = host_fiber
      @socket = NullSocket
      reset_pending_action
    end

    def socket= socket
      @socket = socket if socket
    end

    def close
      socket.close
    end

    def closed?
      socket.closed?
    end

    def gets *args
      defer DeferredAction::Gets.new(args, self)
    end

    def puts *args
      defer DeferredAction::Puts.new(args, self)
    end

    def read *args
      defer DeferredAction::Read.new(args, self)
    end

    def write *args
      defer DeferredAction::Write.new(args, self)
    end

    def pending_read?
      pending_action.read?
    end

    def pending_write?
      pending_action.write?
    end

    def complete_pending_action
      pending_action.perform
    ensure
      reset_pending_action
    end

    def pending_action= action
      unless pending_action == DeferredAction::NoAction
        raise ActionAssigned.new action
      end
      @pending_action = action
    end

    def reset_pending_action
      @pending_action = DeferredAction::NoAction
    end

    def defer action
      self.pending_action = action
      Fiber.yield
    end

    module NullSocket
      def self.closed?
        true
      end
    end

    class ActionAssigned < StandardError
      attr_reader :action

      def initialize existing_action
        @action = existing_action
      end

      def to_s
        "Already have action assigned to #{action}"
      end
    end
  end
end
