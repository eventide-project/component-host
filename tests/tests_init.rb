ENV["LOG_COLOR"] ||= "on"
ENV["CONSOLE_DEVICE"] ||= "stdout"

require_relative "../init"

require "ftest/script"
require "process_host"
require "process_host/controls"
