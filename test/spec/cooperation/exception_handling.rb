require_relative './cooperation_tests_init'

module RaisesError
  class Error < StandardError
    def to_s
      'raises-error'
    end
  end

  def self.start
    raise Error
  end

  def self.change_connection_scheduler(*)
  end
end

describe 'Error handling' do
  errors = {}

  cooperation = ProcessHost::Cooperation.build
  cooperation.register RaisesError
  cooperation.exception_notifier = -> process, error do
    errors[process.to_s] = error.to_s
  end

  begin
    cooperation.start
  rescue RaisesError::Error
  end

  specify 'Errors' do
    assert errors == { 'RaisesError' => 'raises-error' }
  end
end
