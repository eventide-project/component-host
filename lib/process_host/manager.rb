class ProcessHost
  class Manager
    attr_reader :name
    attr_reader :process
    attr_accessor :socket

    def initialize process, name
      @process = process
      @name = name
    end

    def connected?
      if socket then true else false end
    end

    def prepare_socket
      ensure_connected or return
      process.prepare_socket socket if process.respond_to? :prepare_socket
      true
    end

    def ensure_connected
      return true if connected?
      self.socket = process.connect
    end

    def activate_process
      process.receive_socket socket
    ensure
      @socket = nil if socket.closed?
    end
  end
end
