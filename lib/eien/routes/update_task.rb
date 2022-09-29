# frozen_string_literal: true

module Eien
  module Routes
    class UpdateTask < Task
      ALLOWED_ATTRIBUTES = [:enabled, :domains, :path, :process, :port].freeze

      attr_reader :app, :name, :attributes

      def initialize(context, app, name, **attributes)
        @app = Eien.app_from_name(context, app)
        @name = name
        @attributes = attributes
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        the_route = client.get_route(name, app.spec.namespace)
        the_route.spec = (the_route.spec&.to_h || {}).merge(attributes)

        client.update_route(the_route)
      end
    end
  end
end
