require_relative 'test_init'

Runner.('spec/**/*.rb') do |exclude|
  exclude =~ /(_init.rb|\.scratch.rb|\.skip\.rb)\z/
end

Minitest.run
