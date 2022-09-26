# frozen_string_literal: true

module Eien
  module Apps
    class DeleteTask < Task
      attr_reader :name

      def initialize(context, name)
        @name = name
        super(context, nil)
      end

      def run!
        v1_client = kubeclient_builder.build_v1_kubeclient(context)
        eien_client = kubeclient_builder.build_eien_kubeclient(context)

        namespace = eien_client.get_app(name).spec.namespace

        v1_client.delete_namespace(namespace)
        eien_client.delete_app(name)
      end
    end
  end
end
