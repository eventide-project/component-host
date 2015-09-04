class ProcessHost
  class Set
    include Logging

    attr_reader :entries
    attr_writer :logger

    def initialize
      @entries = []
      @sockets = {}
    end

    def []= name, process
      if entries.any? do |sm| sm.name == name end
        fail "Duplicate process named #{name.inspect}"
      end
      sm = StateMachine.new name, process
      entries << sm
    end

    def next_process timeout = 0
      entries.each do |sm|
        sm.connect
        sm.prepare
      end

      socket_map = {}

      entries.each do |sm|
        socket = sm.acquire
        socket_map[socket] = sm if socket
      end

      sleep timeout and return if socket_map.empty?

      readable_sockets, _, _ = IO.select socket_map.keys, [], [], timeout
      readable_sockets = Array(readable_sockets)

      socket_to_read = readable_sockets.first

      socket_map.each do |socket, sm|
        if socket == socket_to_read
          entries.delete sm
          entries.push sm
          sm.receive
        else
          sm.release
        end
      end
    end

    class StateMachine
      attr_reader :name

      def initialize name, process
        @process = process
        @name = name
        @state = :not_connected
      end

      def connect
        return if %i(connected prepared).include? state
        ensure_state! :not_connected
        self.socket = process.connect
      end

      def prepare
        return if %i(not_connected prepared).include? state
        ensure_state! :connected

        if process.respond_to? :prepare_socket
          process.public_send :prepare_socket, socket
        end
        self.state = :prepared
      end

      def acquire
        return nil if state == :not_connected
        ensure_state! :prepared
        self.state = :selecting
        socket
      end

      def receive
        ensure_state! :selecting
        process.receive_socket socket

        if socket.closed?
          self.socket = nil
        else
          self.state = :connected
        end
      end

      def release
        ensure_state! :selecting
        self.state = :prepared
      end

      private

      attr_reader :process
      attr_reader :socket
      attr_accessor :state

      def ensure_state! expected_state
        return if state == expected_state
        event_name = caller_locations[0].label
        raise InvalidEvent.new state, event_name
      end

      def socket= new_socket
        @socket = new_socket

        if new_socket
          @state = :connected
        else
          @state = :not_connected
        end
      end

      class InvalidEvent < StandardError
        attr_reader :state
        attr_reader :event

        def initialize state, event
          @state = state
          @event = event
        end

        def to_s
          "Received #{event.inspect} while in state #{state.inspect}"
        end
      end
    end
  end
end
