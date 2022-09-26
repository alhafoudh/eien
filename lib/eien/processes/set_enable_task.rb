# frozen_string_literal: true

module Eien
  module Processes
    class SetEnableTask < Task
      attr_reader :app, :process, :value

      def initialize(context, app, process, value)
        @app = Eien.app_from_name(context, app)
        @process = process
        @value = value
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        the_process = client.get_process(process, app.spec.namespace)
        the_process.spec.enabled = value

        client.update_process(the_process)
      end
    end
  end
end
