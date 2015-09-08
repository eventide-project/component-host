require "ftest/script"
require "process_host"

require "socket"

class CantConnect
  class Error < StandardError
    def to_s
      "cant-connect"
    end
  end

  def connect io
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

  def connect io
    io.connect @socket
  end

  def next! io
    raise Error
  end
end

errors = {}

builder = ProcessHost::Builder.new
builder.exception_notifier = -> client, error do
  errors[client.class.name] = error.to_s
end

host = builder.()
begin
  host.run do
    add "cant-connect", CantConnect.new
  end
rescue CantConnect::Error => error
end

rd, wr = UNIXSocket.pair
wr.write "data"

host = builder.()
begin
  host.run do
    add "errors-during-operation", ErrorsDuringOperation.new(rd)
  end
rescue ErrorsDuringOperation::Error => error
end

assert errors, :equals => {
  "CantConnect" => "cant-connect",
  "ErrorsDuringOperation" => "errors-during-operation",
}
