mcollective-logstash
--------------------

This is an audit plugin for mcollective that ships events over to an AMQP
broker, ready to be consumed by a logstash agent.

Put logstash.rb in your plugins/audit directory, and add the following
to your server.cfg file:

<pre><code>
rpcaudit = 1
rpcauditprovider = logstash
</code></pre>

You will need to install the 'bunny' gem (tested on 0.7.4) on all machines
using mcollective.

Configurables:

**plugin.logstash.host**: IP or hostname of the AMQP broker (default: localhost)

**plugin.logstash.port**: Port for the AMQP broker (default: 5672)

**plugin.logstash.user**: Username for the broker (default: guest)

**plugin.logstash.password**: Password for the broker (default: guest)

**plugin.logstash.exchange_type**: fanout, direct, or topic. (default: fanout)

**plugin.logstash.durable**: Is the queue durable? (default: true)

**plugin.logstash.persistent**: Should messages persist to disk until read? (default:true)

**plugin.logstash.vhost**: vhost to throw messages to (default: "/")

**plugin.logstash.name**: Name of the exchange (default: "mcollective-logstash")
