module MCollective
  module RPC
    # An audit plugin that just logs to a logstash queue
    #
    #   plugin.logstash.host
    #   plugin.logstash.port
    #   plugin.logstash.exchange_type
    #   plugin.logstash.durable
    #   plugin.logstash.user
    #   plugin.logstash.vhost
    #   plugin.logstash.password
    #   plugin.logstash.persistent
    #   plugin.logstash.name
     
    class Logstash<Audit
      require 'json'
      require 'bunny'

      def audit_request(request, connection)
        now = Time.now.utc
        now_tz = tz = now.utc? ? "Z" : now.strftime("%z")
        now_iso8601 = "%s.%06d%s" % [now.strftime("%Y-%m-%dT%H:%M:%S"), now.tv_usec, now_tz]

        host = Config.instance.pluginconf["logstash.host"] || "localhost"
        port = Config.instance.pluginconf["logstash.port"] || 5672
        vhost = Config.instance.pluginconf["logstash.vhost"] || "/"
        exchange_type = Config.instance.pluginconf["logstash.exchange_type"] || "fanout"
        user = Config.instance.pluginconf["logstash.user"] || "guest"
        password = Config.instance.pluginconf["logstash.password"] || "guest"
        persistent = Config.instance.pluginconf["logstash.persistent"] || true
        durable = Config.instance.pluginconf["logstash.durable"] || true
        name = Config.instance.pluginconf["logstash.name"] || "mcollective-logstash"

        audit_entry = {"@source_host" => Config.instance.identity,
                       "@tags" => [],
                       "@type" => "mcollective-audit",
                       "@source" => "mcollective-audit",
                       "@timestamp" => now_iso8601,
                       "@fields" => {"uniqid" => request.uniqid,
                                     "request_time" => request.time,
                                     "caller" => request.caller,
                                     "callerhost" => request.sender,
                                     "agent" => request.agent,
                                     "action" => request.action,
                                     "data" => request.data.pretty_print_inspect},
                       "@message" => "#{Config.instance.identity}: #{request.caller}@#{request.sender} invoked agent #{request.agent}##{request.action}"}

        bunny = Bunny.new(:host  => host,
                          :port  => port,
                          :vhost => vhost,
                          :user  => user,
                          :pass  => password)

        bunny.start

        exchange = bunny.exchange(name, :type => exchange_type.to_sym, :durable => durable)
        exchange.publish(audit_entry.to_json,
                         :persistent => persistent,
                         :key => "logstash.event.raw.#{Config.instance.identity}.#{audit_entry['@type']}")

        
      end

    end
  end
end
# vi:tabstop=4:expandtab:ai
