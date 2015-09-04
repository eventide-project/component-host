class ProcessHost
  class Iteration
    def self.call(*args)
      instance = new *args
      instance.call
    end

    attr_reader :entries, :timeout

    def initialize entries, timeout
      @entries = entries
      @timeout = timeout
    end

    def call
      prepare
      sleep timeout and return if socket_map.empty?
      socket_to_read = select_socket
      run socket_to_read
    end

    def prepare
      entries.each do |sm|
        sm.connect
        sm.prepare
      end
    end

    def select_socket
      readable_sockets, _, _ = IO.select socket_map.keys, [], [], timeout
      readable_sockets = Array(readable_sockets)
      readable_sockets.first
    end

    def run socket_to_read
      socket_map.each do |socket, sm|
        if socket == socket_to_read
          dispatch sm
        else
          sm.release
        end
      end
    end

    def dispatch sm
      entries.delete sm
      entries.push sm
      sm.receive
    end

    def socket_map
      @socket_map ||= build_socket_map
    end

    def build_socket_map
      entries.each_with_object Hash.new do |sm, socket_map|
        socket = sm.acquire
        socket_map[socket] = sm if socket
      end
    end
  end
end
