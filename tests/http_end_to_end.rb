require_relative "./tests_init"

process_host = ProcessHost.build

t0 = Time.now

client = ProcessHost::Controls::ExampleClient.build
client.logger = logger
server = ProcessHost::Controls::ExampleServer.build
server.logger = logger
requests = client.count

process_host.register server
process_host.register client

process_host.start
logger.debug "Finished processing #{requests} requests"

assert client.count, :equals => 0
