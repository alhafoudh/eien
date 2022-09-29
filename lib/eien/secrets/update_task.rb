# frozen_string_literal: true

module Eien
  module Secrets
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
        secret_name = ::Eien.secret_name(name)
        target_namespace = the_app.spec.namespace

        secret = begin
          client.get_secret(secret_name, target_namespace)
        rescue Kubeclient::ResourceNotFoundError
          new_secret = Kubeclient::Resource.new(
            apiVersion: "v1",
            kind: "Secret",
            metadata: {
              name: secret_name,
              namespace: target_namespace,
              labels: {
                "#{::Eien::LABEL_PREFIX}/app": app_name,
              },
            },
            type: "Opaque",
            data: {
            },
          )
          client.create_secret(new_secret)
        end

        secret.data = prepare_key_pairs(secret)
        client.update_secret(secret)
      end

      private

      def prepare_key_pairs(secret)
        current_key_pairs = (secret.data.to_h || {}).stringify_keys
        encoded_key_pairs = key_pairs.transform_values do |value|
          value.nil? ? value : Base64.strict_encode64(value)
        end
        current_key_pairs.merge(encoded_key_pairs).compact
      end
    end
  end
end
