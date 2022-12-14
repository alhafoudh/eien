# frozen_string_literal: true

module Eien
  module Config
    class ExportTask < Task
      attr_reader :app, :name

      def initialize(context, app, name)
        @app = app
        @name = name
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_v1_kubeclient(context)

        config_map = begin
          client.get_config_map(::Eien.config_map_name(name), the_app.spec.namespace)
        rescue Kubeclient::ResourceNotFoundError
          nil
        end

        return if config_map.nil?

        key_pairs = config_map.data.to_h || {}
        key_pairs.map do |key, value|
          puts "#{key}=#{value}"
        end
      end
    end
  end
end
