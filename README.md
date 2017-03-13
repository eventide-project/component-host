# ProcessHost

Host for independent, autonomous ruby processes implemented as actors using the [actor](https://github.com/ntl/actor) library.

## Usage

Inside your component, define one or more _processes_. In this context, a process merely consists of a start up script for a particular actor or assembly of actors. An example of an assembly of actors would be a stream consumer.

Suppose a component contains two consumers, one for commands, and another for events. The following process will start both consumers:

```ruby
# lib/some_component/process.rb

module SomeComponent
  class Process
    include ProcessHost::Process

    def start
      Consumers::Command.start "someComponent:command"
      Consumers::Event.start "someComponent"
    end
  end
end
```

With this process defined, a start-up script can be defined for the entire component:

```ruby
# bin/start.rb

ProcessHost.start 'some-component' do |host|
  host.register SomeComponent::Process
end
```

## License

The `process-host` library is released under the [MIT License](https://github.com/obsidian-btc/process-host/blob/master/MIT-License.txt).
