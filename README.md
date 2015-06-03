Billiards
=========

A dumb little resource pool.

### Create a Pool

    {:ok, dial_pool} = Billiards.rack(resource: Dialer, workers: 4)

### Billiards initializes worker processes with `start_link/0`.
### You call your pool like it were a single GenServer
    
    {:ok, phone_call_to_jenny } = Billiards.call dial_pool, {:dial, '867-5309'}

Billiards uses a dumb strategy to pick resources from the pool. Right now, it just takes the
first available resource.

If all resources are busy, the calling process will block until a resource is available 
to serve it.

### About

It's not advisable to use this

### TODO

* One/both of:
  * Timeouts, or
  * Monitor failure in processes invoking `Billiards.call`
    A crash there will leave a resource in a 'busy' state.
* Write more tests.