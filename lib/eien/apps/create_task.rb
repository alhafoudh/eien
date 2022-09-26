# frozen_string_literal: true

module Eien
  module Apps
    class CreateTask < Task
      include ActionView::Helpers::DateHelper

      attr_reader :name, :spec_namespace

      def initialize(context, name, namespace)
        @name = name
        @spec_namespace = namespace
        super(context, nil)
      end

      def run!
        create_app!
        ensure_namespace!
      end

      private

      def create_app!
        client = kubeclient_builder.build_eien_kubeclient(context)
        app_resource = Kubeclient::Resource.new(
          metadata: {
            name: name
          },
          spec: {
            namespace: spec_namespace
          }
        )
        client.create_app(app_resource)
      end

      def ensure_namespace!
        client = kubeclient_builder.build_v1_kubeclient(context)
        begin
          client.get_namespace(spec_namespace)
        rescue Kubeclient::ResourceNotFoundError
          create_namespace!(client)
        end
      end

      def create_namespace!(client)
        namespace_resource = Kubeclient::Resource.new(
          metadata: {
            name: spec_namespace
          }
        )
        client.create_namespace(namespace_resource)
      end
    end
  end
end
