require_relative "./tests_init"

process_host = ProcessHost.build

t0 = Time.now

client = ProcessHost::Controls::ExampleClient.build
server = ProcessHost::Controls::ExampleServer.build
requests = client.count

process_host.register server, "example-server"
process_host.register client, "example-client"

process_host.start
logger.debug "Finished processing #{requests} requests"

assert client.count, :equals => 0
