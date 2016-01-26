require_relative './cooperation_spec_init'

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

context 'Error handling' do
  errors = {}

  cooperation = ProcessHost::Cooperation.build
  cooperation.register RaisesError, 'RaisesError'
  cooperation.exception_notifier = -> process, error do
    errors[process] = error.to_s
  end

  begin
    cooperation.start
  rescue RaisesError::Error
  end

  test 'Errors' do
    __logger.data errors
    assert errors == { 'RaisesError' => 'raises-error' }
  end
end
