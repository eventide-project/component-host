require_relative "./cooperation_tests_init"

cooperation = ProcessHost::Cooperation.build

t0 = Time.now

client = ProcessHost::Controls::ExampleClient.build
server = ProcessHost::Controls::ExampleServer.build
requests = client.count

cooperation.register server, "example-server"
cooperation.register client, "example-client"

cooperation.start
logger.debug "Finished processing #{requests} requests"

assert client.count, :equals => 0
