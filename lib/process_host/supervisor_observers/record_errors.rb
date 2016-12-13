module ProcessHost
  module SupervisorObservers
    class RecordErrors
      include Actor::Supervisor::Observer

      attr_writer :record_error_proc

      handle Actor::Messages::ActorCrashed do |msg|
        error = msg.error

        self.(error)
      end

      def call error
        record_error_proc.(error)
      end

      def record_error_proc
        @record_error_proc ||= proc { }
      end
    end
  end
end
