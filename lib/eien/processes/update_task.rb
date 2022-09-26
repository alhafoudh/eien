# frozen_string_literal: true

module Eien
  module Processes
    class UpdateTask < Task
      attr_reader :app, :process, :attributes

      def initialize(context, app, process, **attributes)
        @app = Eien.app_from_name(context, app)
        @process = process
        @attributes = attributes
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        the_process = client.get_process(process, app.spec.namespace)
        the_process.spec = (the_process.spec&.to_h || {}).merge(attributes)

        client.update_process(the_process)
      end
    end
  end
end
