# ProcessHost

Lightweight process host for single threaded, input bound processes. Ideal for TCP services (including HTTP), message buses, log readers, or pub/sub subscribers -- basically, any process that is *reading* on a socket when it is not processing work.

## Why?

Currently, if you want to run, say, an http server *and* a background job processor in the same ruby program, you have to use a full blown asynchronous I/O framework such as Celluloid or Event-Machine.  This changes your architecture fairly significantly.  If you just want to operate more than one process in the same ruby program, but still want to use blocking I/O for each of those processes, ProcessHost can help.

## How it works

ProcessHost uses `IO.select` under the hood to tell the operating system to wake up ruby when any of the processes has data available to read on their sockets. This means each process must expose the underlying socket is reads from to ProcessHost. For instance, if you're writing a web server, this means you'll want to expose the client sockets that are accepting incoming HTTP requests. This is all done through a small API contract between your process and ProcessHost.

In order to make your process available to be hosted, just implement a few methods: `connect`, `receive_socket`, and possibly `prepare_socket`:

| Method name      | Arguments | Purpose                                                         |
| ---------------- | --------- | --------------------------------------------------------------- |
| `connect`        | None      | Returns a new socket that ProcessHost can pass to `IO.select`   |
| `prepare_socket` | `socket`  | Takes any action necessary to set up the socket for reading     |
| `receive_socket` | `socket`  | Called by ProcessHost when your socket is ready to be read from |

At times you will need to recycle your connections -- for instance, when an HTTP server sends back a `Connection: close` header in a response. If you call `#close` on your socket at any time during your `receive_socket` callback, ProcessHost will detect that the socket has been closed and invoke `#connect` to establish a new socket. If you do not call `#close`, your socket will be reused.

Take a look at `tests/http_end_to_end.rb` for a demonstration of an HTTP server and client operating asynchronously with no threads, fibers, or forked subprocesses.

## Heartbeats

ProcessHost will keep a heartbeat updated internally each time it swaps between processes. This ensures that ProcessHost can detect when a single process hangs. Of course, when a single process hangs, ProcessHost is also hung, which means it can't repair itself. However, you can "kick" ProcessHost by sending a `USR1` signal, which will terminate the process if and only if the last heartbeat timestamp is sufficiently old.

## Error handling

It is the responsibility of your processes to handle their own errors. The process host will die if any process raises an unhandled error. The reasoning for this is twofold: one, your operating system likely offers you some sort of process supervision that can restart the process automatically. There is little sense in duplicating that work. Two, your processes are likely related to one another. Is your application still functional if one process dies, but another survives? Do we restart the dead process? What if restarting it causes it to repeat the same error over and over? Error handling is therefore the responsibility of your process.

This doesn't mean, however, that you can't trap errors for **notification** purposes (more on that below). The errors you trap, however, will be immediately re-raised.

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

  # If the last heartbeat is over 12 seconds old, any USR1 signal will cause
  # the process host to die, killing all the processes with it.
  config.heartbeat_threshold_ms = 12000

  # Deliver a message to your sysadmin's pager
  config.exception_notifier = -> process, error do
    Mailer.deliver #etc
  end
end

# Adds processes to the host
process_host.add MyWebApplication.new
process_host.add MyWorker.new

# This will take over the current process
process_host.run
```
