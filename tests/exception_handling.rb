require_relative "./tests_init"

module RaisesError
  class Error < StandardError
    def to_s
      "raises-error"
    end
  end

  def self.start
    raise Error
  end

  def self.change_connection_policy(*)
  end
end

errors = {}

process_host = ProcessHost.build
process_host.register RaisesError
process_host.exception_notifier = -> process, error do
  errors[process.to_s] = error.to_s
end

begin
  process_host.run
rescue RaisesError::Error
end

assert errors, :equals => { "RaisesError" => "raises-error" }
