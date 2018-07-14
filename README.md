# ComponentHost

Host for ruby components that use the [actor](https://github.com/ntl/actor) library.

## Usage

Inside your component, define a _start script_. In this context, a start script merely consists of ruby code that starts a particular actor or assembly of actors. An example of an actor would be a consumer.

Suppose a component would need two consumers running: one for all commands, and another for all events. The following start up script will start both consumers:

```ruby
# lib/some_component/start.rb

module SomeComponent
  module Start
    def self.call
      Consumers::Command.start("someComponent:command")
      Consumers::Event.start("someComponent")
    end
  end
end
```

With this start script included with the component, an executable file that hosts the component can be written:

```ruby
# bin/start.rb

ComponentHost.start 'some-component' do |host|
  host.register SomeComponent::Start
end
```

## License

The `component-host` library is released under the [MIT License](https://github.com/eventide-project/component-host/blob/master/MIT-License.txt).
