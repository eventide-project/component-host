ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_COLOR'] ||= 'on'
ENV['LOG_LEVEL'] ||= 'trace'

puts RUBY_DESCRIPTION

require_relative "../init"

require "process_host"
require "process_host/controls"
require "runner"
