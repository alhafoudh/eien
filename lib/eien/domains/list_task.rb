# frozen_string_literal: true

module Eien
  module Domains
    class ListTask < Task
      attr_reader :app

      def initialize(context, app)
        @app = app
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_eien_kubeclient(context)
        domains = client.get_domains(namespace: the_app.spec.namespace)
        table = TTY::Table.new(
          [
            colorize("DOMAIN").yellow,
            colorize("ENABLED").yellow,
            colorize("NAME").yellow,
            colorize("AGE").yellow,
          ],
          domains.map do |domain|
            [
              domain.metadata.name,
              summarize_enabled(domain.spec.enabled),
              domain.spec.domain,
              summarize_age(Time.parse(domain.metadata.creationTimestamp)),
            ]
          end,
        )

        output = table.render(:basic)
        puts output
      end
    end
  end
end
