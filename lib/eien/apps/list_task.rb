# frozen_string_literal: true

module Eien
  module Apps
    class ListTask < Task
      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        apps = client.get_apps
        table = TTY::Table.new(
          [
            colorize("NAME").yellow,
            colorize("NAMESPACE").yellow,
            colorize("AGE").yellow,
          ],
          apps.map do |app|
            [
              app.metadata.name,
              app.spec.namespace,
              summarize_age(Time.parse(app.metadata.creationTimestamp)),
            ]
          end,
        )

        output = table.render(:basic)
        puts output
      end
    end
  end
end
