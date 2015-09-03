require "ftest/script"
require "process_host"

require "socket"

class CantConnect
  class Error < StandardError
    def to_s
      "cant-connect"
    end
  end

  def connect
    raise Error
  end
end

class ErrorsDuringOperation
  class Error < StandardError
    def to_s
      "errors-during-operation"
    end
  end

  def initialize socket
    @socket = socket
  end

  def connect
    @socket
  end

  def receive_socket socket
    raise Error
  end
end

errors = {}

builder = ProcessHost::Builder.new
builder.exception_notifier = -> process, error do
  errors[process.class.name] = error.to_s
end

host = builder.()
host.add CantConnect.new
begin
  host.run
rescue CantConnect::Error => error
end

rd, wr = UNIXSocket.pair
wr.write "data"

host = builder.()
host.add ErrorsDuringOperation.new rd
begin
  host.run
rescue ErrorsDuringOperation::Error => error
end

assert errors, :equals => {
  "CantConnect" => "cant-connect",
  "ErrorsDuringOperation" => "errors-during-operation",
}
