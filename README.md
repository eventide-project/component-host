# ProcessHost

Lightweight process host for single threaded, input bound processes. Ideal for TCP services (including HTTP), message buses, log readers, or pub/sub subscribers -- basically, any process that waits around for a TCP socket to supply work.

## Why?

Currently, if you want to run, say, an http server *and* a background job processor in the same ruby program, you have to use a full blown asynchronous I/O framework such as Celluloid or Event-Machine.  This changes your architecture fairly significantly.  If you just want to operate more than one process in the same ruby program, but still want to use blocking I/O for each of those processes, ProcessHost can help.
