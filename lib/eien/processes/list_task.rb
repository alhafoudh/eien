# frozen_string_literal: true

module Eien
  module Processes
    class ListTask < Task
      include ActionView::Helpers::DateHelper

      attr_reader :app

      def initialize(context, app)
        @app = app
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_eien_kubeclient(context)
        processes = client.get_processes(namespace: the_app.spec.namespace)
        table = TTY::Table.new(
          [
            ColorizedString.new("NAME").yellow,
            ColorizedString.new("ENABLED").yellow,
            ColorizedString.new("IMAGE").yellow,
            ColorizedString.new("REPLICAS").yellow,
            ColorizedString.new("COMMAND").yellow,
            ColorizedString.new("PORTS").yellow,
            ColorizedString.new("AGE").yellow
          ],
          processes.map do |process|
            [
              process.metadata.name,
              process.spec.enabled,
              process.spec.image,
              process.spec.replicas,
              summarize_command(process.spec.command),
              summarize_ports(process.spec.ports),
              time_ago_in_words(Time.parse(process.metadata.creationTimestamp), include_seconds: true)
            ].map do |value|
              if process.spec.enabled
                value.to_s
              else
                ColorizedString.new(value.to_s).light_black
              end
            end
          end
        )

        output = table.render(:basic)
        puts output
      end

      private

      def summarize_command(command)
        command&.join(" ") || "<none>"
      end

      def summarize_ports(ports)
        ports.map do |port|
          "#{port.containerPort}.#{port.name}"
        end.join(", ")
      end
    end
  end
end
