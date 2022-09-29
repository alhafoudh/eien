# frozen_string_literal: true

module Eien
  module Routes
    class DeleteTask < Task
      attr_reader :app, :name

      def initialize(context, app, name)
        @app = Eien.app_from_name(context, app)
        @name = name
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        client.delete_route(name, app.spec.namespace)
      end
    end
  end
end
