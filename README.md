# ProcessHost

Lightweight process host for single threaded, input bound processes. Ideal for TCP services (including HTTP), message buses, log readers, or pub/sub subscribers -- basically, any process that waits around for a socket to supply work.

## Why?

Currently, if you want to run, say, an http server *and* a background job processor in the same ruby program, you have to use a full blown asynchronous I/O framework such as Celluloid or Event-Machine.  This changes your architecture fairly significantly.  If you just want to operate more than one process in the same ruby program, but still want to use blocking I/O for each of those processes, ProcessHost can help.

## How it works

ProcessHost uses `IO.select` under the hood to tell the operating system to wake up ruby when any of the processes has data available to read on their sockets. This means each process must expose the underlying socket is reads from to ProcessHost. For instance, if you're writing a web server, this means you'll want to expose the client sockets that are accepting incoming HTTP requests. This is all done through a small API contract between your process and ProcessHost.

In order to make your process available to be hosted, just implement to methods: `#connect` and `#start`.

##### #connect

The `#connect` method will get passed an object, named `io` in subsequent examples, and your responsibility is to pass in a socket on `io` via assignment. If that sounds confusing, here is an example:

```ruby
class MyProcess
  def self.connect io
    io.socket = TCPSocket.new "localhost", 9999
  end
end
```

Basically, inside your `#connect` method, you'll want to establish an actual socket connection to something, and pass that back to the `io` argument you receive. If your connection raises an `Errno::ECONNREFUSED` error, ProcessHost will rescue that error and try again later.

##### #start

When your process instance has given the `io` a connection, ProcessHost will then spawn a Fiber and invoke `#start` inside of it. The `io` object passed in actually implements a few "blocking" I/O methods: `gets`, `puts`, `read`, and `write`. Behind the scenes, ProcessHost suspends your process and resumes it once the socket is be ready for reading or writing.

At times you will need to recycle your sockets -- for instance, when an HTTP server sends back a `Connection: close` header in a response. If you call `#close` on your socket at any time during your `start` method, ProcessHost will detect that the socket has been closed and invoke `#connect` to establish a new socket. If you do not call `#close`, your socket will be reused. The very first time your `#start` method requests IO access, `#connect` will be used to setup an initial connection.

Take a look at `tests/http_end_to_end.rb` for a demonstration of an HTTP server and client operating asynchronously with no threads, fibers, or forked subprocesses.

## Watchdog

ProcessHost can keep a heartbeat updated internally each time it swaps between processes. This ensures that ProcessHost can detect when a single process hangs. Simply set `watchdog_timeout` in your configuration block to activate the watchdog (more that below). This watchdog gets reset automatically between each iteration of the main polling loop.

## Error handling

It is the responsibility of your processes to handle their own errors. The process host will die if any process raises an unhandled error. The reasoning for this is twofold: one, your operating system likely offers you some sort of process supervision that can restart the process automatically. There is little sense in duplicating that work. Two, your processes are likely related to one another. Is your application still functional if one process dies, but another survives? Do we restart the dead process? What if restarting it causes it to repeat the same error over and over? Error handling is therefore the responsibility of your process.

This doesn't mean, however, that you can't trap errors for *notification* purposes (more on that below). The errors you trap, however, will be immediately re-raised.

## Usage

Once you have a process object that meets ProcessHost's requirements (see "How it works," above), then you can launch your process host with a few lines of code.

```ruby
# First you want to load your code
require "./path/to/application"
require "process_host"

process_host = ProcessHost.build do |config|
  # Log to stdout
  config.logger = Logger.new $stdout

  # Every time we trigger IO.select to wait for new work for any of the
  # processes, we set the timeout to 50ms. This means that if there is total
  # silence on all the sockets, we'll be waking up and retriggering IO.select
  # every 50ms.
  config.poll_period_ms = 50

  # Activate the watchdog and configure it to kill the host and processes if
  # a single round trip through the main loop takes longer than the configured
  # threshold of 12 seconds.
  config.watchdog_timeout = 12

  # Deliver a message to your sysadmin's pager
  config.exception_notifier = -> process, error do
    Mailer.deliver #etc
  end
end

# Runs the host, taking over the current process
process_host.run do
  add MyWebApplication.new
  add MyWorker.new
end
```
