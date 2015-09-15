require_relative "./tests_init"

# Test iterates n times
requests = 100
# Persist connections n times before closing connection
max_per_connection = 50

process_host = ProcessHost.build

t0 = Time.now

client = ProcessHost::Controls::ExampleClient.build requests
server = ProcessHost::Controls::ExampleServer.build max_per_connection

process_host.register server
process_host.register client

process_host.run
logger.debug "Finished processing #{requests} requests"

assert client.count, :equals => 0
