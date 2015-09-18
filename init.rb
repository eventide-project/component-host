require "bundler"
Bundler.setup

lib_dir = File.expand_path "../lib", __FILE__
unless $LOAD_PATH.include? lib_dir
  $LOAD_PATH << lib_dir
end

require "process_host"
