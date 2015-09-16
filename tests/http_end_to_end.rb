require_relative "./tests_init"

process_host = ProcessHost.build

t0 = Time.now

client = ProcessHost::Controls::ExampleClient.build
requests = client.count
client.logger = logger
server = ProcessHost::Controls::ExampleServer.build
server.logger = logger

process_host.register server
process_host.register client

process_host.run
logger.debug "Finished processing #{requests} requests"

assert client.count, :equals => 0
