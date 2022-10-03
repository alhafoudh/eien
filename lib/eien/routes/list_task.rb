# frozen_string_literal: true

module Eien
  module Routes
    class ListTask < Task
      attr_reader :app

      def initialize(context, app)
        @app = app
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_eien_kubeclient(context)
        routees = client.get_routes(namespace: the_app.spec.namespace)
        table = TTY::Table.new(
          [
            colorize("NAME").yellow,
            colorize("ENABLED").yellow,
            colorize("DOMAINS").yellow,
            colorize("PATH").yellow,
            colorize("PROCESS").yellow,
            colorize("PORT").yellow,
            colorize("AGE").yellow,
          ],
          routees.map do |route|
            [
              route.metadata.name,
              summarize_enabled(route.spec.enabled),
              summarize_domains(route.spec.domains),
              route.spec.path,
              route.spec.process,
              route.spec.port,
              time_ago_in_words(Time.parse(route.metadata.creationTimestamp), include_seconds: true),
            ]
          end,
        )

        output = table.render(:basic)
        puts output
      end

      private

      def summarize_domains(domains)
        domains&.join(", ") || none_string
      end
    end
  end
end
