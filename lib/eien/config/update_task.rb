# frozen_string_literal: true

module Eien
  module Config
    class UpdateTask < Task
      attr_reader :app, :name, :key_pairs

      def initialize(context, app, name, **key_pairs)
        @app = app
        @name = name
        @key_pairs = key_pairs
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_v1_kubeclient(context)

        app_name = the_app.metadata.name
        config_map_name = ::Eien.config_map_name(name)
        target_namespace = the_app.spec.namespace

        config_map = begin
          client.get_config_map(config_map_name, target_namespace)
        rescue Kubeclient::ResourceNotFoundError
          new_config_map = Kubeclient::Resource.new(
            apiVersion: "v1",
            kind: "config_map",
            metadata: {
              name: config_map_name,
              namespace: target_namespace,
              labels: {
                "#{::Eien::LABEL_PREFIX}/app": app_name,
              },
            },
            data: {
            },
          )
          client.create_config_map(new_config_map)
        end

        config_map.data = prepare_key_pairs(config_map)
        client.update_config_map(config_map)
      end

      private

      def prepare_key_pairs(config_map)
        current_key_pairs = (config_map.data.to_h || {}).stringify_keys
        current_key_pairs.merge(key_pairs).compact
      end
    end
  end
end
