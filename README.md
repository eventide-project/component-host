# ComponentHost

Host for Ruby components that use the [actor](https://github.com/ntl/actor) library.

## Usage

``` ruby
# The "component initiator" binds consumers to their streams and starts
# the consumers
# Until this point, handlers have no knowledge of which streams they process
# Starting the consumers starts the stream readers and gets messages flowing
# into the consumer's handlers
module SomeComponent
  def self.call
    command_stream_name = 'something:command'
    SomeConsumer.start(command_stream_name)
  end
end

# ComponentHost is the runnable part of the service
# Register a component module with the component host, then start the host
# and messages sent to its streams are dispatched to the handlers
component_name = 'some-component'
ComponentHost.start(component_name) do |host|
  host.register(SomeComponent)
end
```

## More Documentation

See the [Eventide documentation site](http://docs.eventide-project.org) for more information, examples, and user guides.

## License

The `component-host` library is released under the [MIT License](https://github.com/eventide-project/component-host/blob/master/MIT-License.txt).
