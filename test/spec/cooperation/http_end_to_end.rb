require_relative "./cooperation_spec_init"

context "HTTP end to end" do
  cooperation = ProcessHost::Cooperation.build

  t0 = Time.now

  client = ProcessHost::Controls::ExampleClient.build
  server = ProcessHost::Controls::ExampleServer.build
  requests = client.count

  cooperation.register server, "example-server"
  cooperation.register client, "example-client"

  cooperation.start

  test "Client count" do
    assert client.count == 0
  end
end
