# frozen_string_literal: true

module Eien
  module CLI
    class Deploy < CLI
      class_option :context, aliases: [:c]
      class_option :app, aliases: [:a]

      desc "generate", "generates app resources and prints them to terimal"

      def generate
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          resources = ::Eien::Deploy::GenerateTask.new(
            context,
            app,
          ).run!
          puts resources
            .map(&:to_h)
            .map(&:deep_stringify_keys)
            .map(&:to_yaml)
            .join("\n")
        end
      end

      desc "apply", "deploys app resources to cluster"

      def apply
        rescue_and_exit do
          context = ::Eien.context_or_default(options[:context])
          app = ::Eien.app_or_default(options[:app])

          require_context!(context)
          require_app!(app)

          ::Eien::Deploy::ApplyTask.new(
            context,
            app,
          ).run!
        end
      end
    end
  end
end
