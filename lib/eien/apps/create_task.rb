# frozen_string_literal: true

module Eien
  module Apps
    class CreateTask < Task
      include ActionView::Helpers::DateHelper

      attr_reader :name, :spec_namespace

      def initialize(name, namespace, context)
        @name = name
        @spec_namespace = namespace
        super(context, nil)
      end

      def run!
        client = kubeclient_builder.build_eien_kubeclient(context)

        resource = Kubeclient::Resource.new(
          metadata: {
            name: name
          },
          spec: {
            namespace: spec_namespace
          }
        )
        client.create_app(resource)
      end
    end
  end
end
