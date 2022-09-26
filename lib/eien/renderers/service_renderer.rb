module Eien
  module Renderers
    class ServiceRenderer
      include ActionView::Helpers::DateHelper

      attr_reader :service

      def initialize(service)
        @service = service
      end

      def render
        created_time_ago = time_ago_in_words(created_at, include_seconds: true)

        status = service.status

        ports_message = service.spec.ports.each_with_object([]) do |port, lines|
          lines << "#{port.nodePort} -> #{port.port}/#{port.name} -> #{port.targetPort}"
        end.join("\n")

        rows = [
          ["name", ColorizedString.new(name).light_magenta],
          ["", ""],
          ["created", "#{created_time_ago} ago"],
          ["", ""],
          ["cluster IP", service.spec.clusterIP],
          ["", ""],
          ["ports", ports_message],
          ["", ""],
          ["external IP", external_ip_status(service)]
        ]
        TTY::Table.new(rows).render(:unicode, multiline: true, padding: [0, 1])
      end

      private

      def external_ip_status(service)
        status = service.status
        return ColorizedString.new("<none>").light_black unless status.loadBalancer.ingress

        status.loadBalancer.ingress.map(&:ip).map do |ip|
          "#{ip}\n" +
            service.spec.ports.each_with_object([]) do |port, lines|
              lines << "#{port.name}://#{ip}:#{port.port}"
            end.join("\n")
        end.join("\n\n")
      end

      def name
        service.metadata.name
      end

      def created_at
        Time.parse(service.metadata.creationTimestamp)
      end
    end
  end
end