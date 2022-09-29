# frozen_string_literal: true

module Eien
  module Routes
    class CreateTask < Task
      attr_reader :app, :name, :attributes

      def initialize(context, app, name, **attributes)
        @app = Eien.app_from_name(context, app)
        @name = name
        @attributes = attributes
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)

        route = Kubeclient::Resource.new(
          metadata: {
            name: name,
            namespace: app.spec.namespace,
            labels: {
              "#{::Eien::LABEL_PREFIX}/app": app.metadata.name,
            },
          },
          spec: attributes,
        )
        client.create_route(route)
      end
    end
  end
end
