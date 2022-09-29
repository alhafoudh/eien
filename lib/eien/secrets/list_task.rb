# frozen_string_literal: true

module Eien
  module Secrets
    class ListTask < Task
      attr_reader :app, :name

      def initialize(context, app, name)
        @app = app
        @name = name
        super(context)
      end

      def run!
        the_app = Eien.app_from_name(context, app)
        client = kubeclient_builder.build_v1_kubeclient(context)

        secret = begin
          client.get_secret(::Eien.secret_name(name), the_app.spec.namespace)
        rescue Kubeclient::ResourceNotFoundError
          nil
        end

        return if secret.nil?

        key_pairs = secret.data.to_h || {}
        table = TTY::Table.new(
          [
            colorize("KEY").yellow,
            colorize("VALUE").yellow,
          ],
          key_pairs.map do |key, value|
            [
              key,
              Base64.decode64(value),
            ]
          end,
        )

        output = table.render(:basic)
        puts output
      end
    end
  end
end
