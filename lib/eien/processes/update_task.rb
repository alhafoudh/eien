# frozen_string_literal: true

module Eien
  module Processes
    class UpdateTask < Task
      ALLOWED_ATTRIBUTES = [:enabled, :image, :config, :secret, :command, :replicas, :ports].freeze

      attr_reader :app, :name, :attributes

      def initialize(context, app, name, **attributes)
        @app = Eien.app_from_name(context, app)
        @name = name
        @attributes = attributes
        super(context)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)
        the_process = client.get_process(name, app.spec.namespace)
        the_process.spec = (the_process.spec&.to_h || {}).merge(attributes)

        client.update_process(the_process)
      end
    end
  end
end
