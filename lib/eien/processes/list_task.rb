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
            colorize("NAME").yellow,
            colorize("ENABLED").yellow,
            colorize("IMAGE").yellow,
            colorize("REPLICAS").yellow,
            colorize("COMMAND").yellow,
            colorize("PORTS").yellow,
            colorize("AGE").yellow
          ],
          processes.map do |process|
            [
              process.metadata.name,
              summarize_enabled(process.spec.enabled),
              process.spec.image,
              process.spec.replicas,
              summarize_command(process.spec.command),
              summarize_ports(process.spec.ports.to_h),
              time_ago_in_words(Time.parse(process.metadata.creationTimestamp), include_seconds: true)
            ]
          end
        )

        output = table.render(:basic)
        puts output
      end

      private

      def summarize_command(command)
        command&.join(" ") || none_string
      end

      def summarize_ports(ports)
        if ports.empty?
          none_string
        else
          ports.map do |name, port|
            "#{port}/#{name}"
          end.join(" ")
        end
      end

      def none_string
        colorize("<none>").light_black
      end
    end
  end
end
